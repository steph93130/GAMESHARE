class GamesController < ApplicationController
  beforeaction :game_set, only: [:show, :destroy]
  def index
    if params[:profile_id]
      @profile_user = User.find(params[:profile_id])
      @games = policy_scope(Game).where(user: @profile_user)
    else
      @address = params[:query]
      result = Geocoder.search(@address).first if @address.present?
      @user_markers = result ? [{ lat: result.latitude, lng: result.longitude }] : []
      @games = policy_scope(Game).where(available: true).near(@address, 5)
      @game_markers = @games.where.not(lat: nil, lng: nil).map do |game|
        { lat: game.lat, lng: game.lng }
      end
    end
  end

  def show
    @game = Game.find(params[:id])
    authorize @game
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
