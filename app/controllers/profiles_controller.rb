class ProfilesController < ApplicationController
  def show
    @user = current_user
    @games = current_user.games
    @game = Game.new
    authorize :profile
  end

  def borrow
    @user = current_user
    @chats = current_user.chats.all
        authorize :profile

    # raise

    # Pages lié a la récupération des booking de l'emprunteur

  end

  def owner
    @user = current_user
    @games = current_user.games
    authorize :profile
    raise
    #page lié pret de jeux

  end
  # def show2
  #   @games = current_user.games
  #   @game = Game.new
  #   @user = current_user
  #   authorize :profile
  # end
end
