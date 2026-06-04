class GamesController < ApplicationController
  def index
    @address = params[:query]
    @games = policy_scope(Game).where(available: true).near(@address, 5)
    # @games = Game.near(address, 0.3)
    @markers = @games.where.not(lat: nil, lng: nil).map do |game|
      {
        lat: game.lat,
        lng: game.lng
      }
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

  private

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
