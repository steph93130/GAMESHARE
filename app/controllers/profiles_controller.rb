class ProfilesController < ApplicationController
  def show
    @user = current_user
    authorize :profile
  end

  def show2
    @games = current_user.games
    @game = Game.new
    @user = current_user
    authorize :profile
  end
end
