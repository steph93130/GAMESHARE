class GamesController < ApplicationController
  before_action :game_set, only: [:show, :destroy]
  def index
    @games = policy_scope(Game).where(available: true)
    if params[:query].present?
      @address = params[:query]
      result = Geocoder.search(@address).first
      @user_markers = [{
        lat: result.latitude,
        lng: result.longitude,
        marker_html: render_to_string(partial: "marker_user")
      }]

      @games = @games.near(@address, 5)
      # @games = Game.near(address, 0.3)
    end
    @game_markers = @games.where.not(lat: nil, lng: nil).map do |game|
      { lat: game.lat, lng: game.lng,
        info_window_html: render_to_string(partial: "info_window", locals: { game: game }),
        marker_html: render_to_string(partial: "marker_game") }
    end
  end

  def show
    @game = Game.find(params[:id])
    authorize @game
    @address = params[:query]
  end

  def new
    @game = Game.new
    authorize @game
  end

  def create
    @game = Game.new(game_params)
    @game.user = current_user
    # @game.address = current_user.address
    authorize @game

    if @game.save
      redirect_to @game
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @game.destroy
    redirect_to profile_path, status: :see_other
  end

  def fetch_rules
    title = params[:title].to_s.strip
    image = params[:image] # ActionDispatch::Http::UploadedFile ou nil

    return render json: { error: "Le titre du jeu est requis." }, status: :bad_request if title.blank?

    prompt = <<~PROMPT
      Tu es un expert en jeux de société. Donne-moi les règles de base du jeu "#{title}" en français.
      Réponds UNIQUEMENT en HTML, sans balises <html>, <head> ou <body>.
      Structure ta réponse ainsi :
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

    render json: { rules: response.content }, content_type: "application/json"

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
