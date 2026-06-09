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
    @chats = current_user.chats.all
    @bookings = borrow_booking
    @bs = borrow_status
  end

  def owner # prêteur
    @games = current_user.games
    @game = Game.new
    @bookings = Booking.all
    @user = current_user
    authorize :profile
    @bs = owner_status
  end

  private 

  def borrow_booking
    bookings = []
    @chats.each do |chat|
      if chat.booking.nil? == false
        bookings << chat.booking
      end
    
    end
    bookings.sort_by { |b| b.created_at }.reverse
  end

  def borrow_status
    submited = []
    accepted = []
    validated = []
    returned = []
    closed = []
    @chats.each do |chat|
      if chat.booking.nil? == false
        if chat.booking.status == "submited"
          submited << chat.booking
        elsif chat.booking.status == "accepted"
          accepted << chat.booking
        elsif chat.booking.status == "validated"
          validated << chat.booking
        elsif chat.booking.status == "returned"
          returned << chat.booking
        elsif chat.booking.status == "closed"
          closed << chat.booking
        end
      end
    end
    bookings = {
      submited: submited,
      accepted: accepted,
      validated: validated,
      returned: returned,
      closed: closed
    }
  end
  def owner_status
    submited = []
    accepted = []
    validated = []
    returned = []
    closed = []
    @games.each do |game|
      game.chats.each do |chat|
        if chat.booking.nil? == false
          if chat.booking.status == "submited"
            submited << chat.booking
          elsif chat.booking.status == "accepted"
            accepted << chat.booking
          elsif chat.booking.status == "validated"
            validated << chat.booking
          elsif chat.booking.status == "returned"
            returned << chat.booking
          elsif chat.booking.status == "closed"
            closed << chat.booking
          end
        end
      end
    end
    bookings = {
      submited: submited,
      accepted: accepted,
      validated: validated,
      returned: returned,
      closed: closed
    }
  end
end
