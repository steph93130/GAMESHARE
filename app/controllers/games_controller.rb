class GamesController < ApplicationController
  before_action :game_set, only: %i[show edit update destroy]

  def index
    @games = policy_scope(Game).where(available: true)

    if params[:query].present?
      @address = params[:query]
      result = Geocoder.search(@address).first

      if result
        @user_markers = [{
          lat: result.latitude,
          lng: result.longitude,
          marker_html: render_to_string(partial: "marker_user")
        }]

        @games = @games.near(@address, 5)
      end
    end

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
      redirect_to @game
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
      redirect_to game_path(@game), notice: "Jeu modifié avec succès"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @game
    @game.destroy
    redirect_to profile_path, status: :see_other
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
