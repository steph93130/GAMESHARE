class ProfilesController < ApplicationController
  def show
    @user = current_user
    @games = current_user.games
    @game = Game.new
    authorize :profile
  end

  def borrow
    @games = current_user.games
    @game = Game.new
    @user = current_user
    authorize :profile
    @chats = current_user.chats.all
    @bookings = borrow_booking
    
  end

  def owner
    @games = current_user.games
    @game = Game.new
    @user = current_user
    authorize :profile
  end

  private 

  def borrow_booking
    bookings = []
    @chats.each do |chat|
      if chat.booking.nil? == false
        bookings << chat.booking
      end
    
    end
    bookings
  end

end
