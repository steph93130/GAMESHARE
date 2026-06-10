class GamesController < ApplicationController
  before_action :game_set, only: %i[show edit update destroy toggle_availability]
  skip_after_action :verify_authorized, only: :fetch_rules

  def index
    @games = policy_scope(Game).where(available: true).where.not(user: current_user)
    if params[:query].present?
      @address = params[:query]

      if @address.match?(/\A-?\d+\.?\d*,-?\d+\.?\d*\z/)
        lat, lng = @address.split(",").map(&:to_f)
        @user_markers = [{
          lat: lat,
          lng: lng,
          marker_html: render_to_string(partial: "marker_user")
        }]
        @games = @games.near([lat, lng], 10)
      else
        result = Geocoder.search(@address).first
        if result
          @user_markers = [{
            lat: result.latitude,
            lng: result.longitude,
            marker_html: render_to_string(partial: "marker_user")
          }]
          @games = @games.near(@address, 10)
        end
      end
    end

    base = Game.where(available: true).where.not(user: current_user).distinct
    @categories     = base.pluck(:category).compact.sort
    @player_numbers = base.pluck(:player_number).compact.sort
    @ages           = base.pluck(:age).compact.sort

    @games = @games.where(category: params[:category]) if params[:category].present?
    @games = @games.where("player_number >= ?", params[:player_number].to_i) if params[:player_number].present?
    @games = @games.where("age >= ?", params[:age].to_i)        if params[:age].present?

    @game_markers = @games.where.not(lat: nil, lng: nil).map do |game|
      {
        lat: game.lat,
        lng: game.lng,
        info_window_html: render_to_string(partial: "info_window", locals: { game: game }),
        marker_html: render_to_string(partial: "marker_game")
      }
    end
  end

  def show
    authorize @game
    @address = params[:query]
    inactive = %w[declined closed]
    if current_user == @game.user
      @inline_chat = @game.chats.includes(:booking).to_a
                          .reject { |c| inactive.include?(c.booking&.status) }
                          .max_by(&:created_at)
    else
      @inline_chat = @game.chats.includes(:booking).where(user: current_user).to_a
                          .find { |c| !inactive.include?(c.booking&.status) }
    end
  end

  def new
    @game = Game.new
    authorize @game
  end

  def create
    @game = Game.new(game_params)
    @game.user = current_user
    authorize @game

    if @game.save
      redirect_to game_path(@game)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @game
  end

  def update
    authorize @game

    if @game.update(game_params)
      broadcast_flash_to(current_user, "Jeu modifié avec succès !")
      redirect_to game_path(@game)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def toggle_availability
    authorize @game, :update?
    @game.update!(available: !@game.available)
    redirect_to owner_path, status: :see_other
  end

  def destroy
    authorize @game
    @game.destroy
    redirect_to profile_path, status: :see_other
  end

  def fetch_rules
    title = params[:title].to_s.strip
    image = params[:image]

    return render json: { error: "Le titre du jeu est requis." }, status: :bad_request if title.blank?

    prompt = <<~PROMPT
      Tu es un expert en jeux de société. Pour le jeu "#{title}", génère en français :
      1. Une description du jeu en 1 à 2 phrases maximum (texte brut sans HTML, accessible à tous).
      2. Les règles complètes en HTML structuré.

      Réponds UNIQUEMENT avec un objet JSON valide, sans balises markdown. Structure exacte :
      {
        "description": "texte simple ici",
        "rules": "html des règles ici"
      }

      Pour les règles HTML :
      - <h3> pour chaque section (Objectif, Mise en place, Déroulement d'un tour, Fin de partie, Conseils)
      - <p> pour les paragraphes explicatifs
      - <ul><li> pour les listes d'actions ou de matériel
      - <strong> pour les termes-clés
      Sois concis mais suffisamment complet pour qu'un débutant puisse jouer.
    PROMPT

    chat = RubyLLM.chat(model: "gpt-4o")

    response = if image.present?
                 chat.ask(prompt, with: { image: image.path })
               else
                 chat.ask(prompt)
               end

    content = response.content.strip.gsub(/\A```(?:json)?\n?/, "").gsub(/\n?```\z/, "")
    data = JSON.parse(content)

    render json: { rules: data["rules"], description: data["description"] }, content_type: "application/json"
  rescue JSON::ParserError
    render json: { error: "L'IA a retourné un format invalide. Réessayez." }, status: :unprocessable_entity
  rescue RubyLLM::Error => e
    render json: { error: "L'IA n'a pas pu répondre : #{e.message}" }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { error: "Erreur inattendue : #{e.message}" }, status: :internal_server_error
  end

  private

  def game_set
    @game = Game.find(params[:id])
  end

  def game_params
    params.require(:game).permit(
      :title,
      :condition,
      :picture,
      :rent_duration,
      :age,
      :player_number,
      :category,
      :description,
      :rules,
      :available,
      :deposit
    )
  end
end
