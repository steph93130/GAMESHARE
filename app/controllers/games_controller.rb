class GamesController < ApplicationController
  beforeaction :game_set, only: [:show, :destroy]
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
