class ProfilesController < ApplicationController
  def show
    @user = current_user
    @games = current_user.games
    @game = Game.new
    authorize :profile
  end

  def borrow # emprunteur
    @games = current_user.games
    @game = Game.new
    @user = current_user
    authorize :profile
  end

  def owner # prêteur
    @games = current_user.games
    @game = Game.new
    @bookings = Booking.all
    @user = current_user
    authorize :profile
  end
end
