class GamesController < ApplicationController
  def index
    @games = policy_scope(Game)
  end

  def show
    @game = Game.find(params[:id])
  end

  def new
    @game = Game.new
  end

  def create
    @game = Game.new(game_params)
    @game.user = current_user

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
