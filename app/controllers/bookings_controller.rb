class BookingsController < ApplicationController
    before_action :set_booking, only: [:accept, :validate]
    
    def create
        @chat = Chat.find(params[:chat_id])
        @booking = Booking.new(game: @chat.game, user: current_user, chat: @chat )
        authorize @booking
        if @booking.save
            redirect_to @chat
        else
            render "chat/show", status: :unprocessable_entity
        end
    end
  end

    # preteur
    def accept
        # raise
        authorize @booking
        @booking.update(status: :accepted)
        # preteur redirection au profil et visuel de la notification dans sa ludo!! a chaque action
        # emprunteur message chat system allez voir votre profil section emprunt et notification
    end
    
    def decline
        #annulation du booking
    end
    
    # emprunteur
    def validate
        authorize @booking
        @booking.update(status: :validated)
    end

    # emprunteur
    def give_back
    
    end

    # preteur
    def close

    end
    
    private

    def set_booking
        @booking = Booking.find(params[:id])
    end
end
