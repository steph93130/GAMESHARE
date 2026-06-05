class BookingsController < ApplicationController
    before_action :set_booking, only: [:accept, :decline, :validate]
    
    def create
        @chat = Chat.find(params[:chat_id])
        @booking = Booking.new(game: @chat.game, user: current_user, chat: @chat )
        authorize @booking
        if @booking.save
            @system_message = @booking.chat.messages.create(chat_id: @booking.chat, user: current_user, content: "SYSTEM MESSAGE /=> #{current_user.username} demande le prêt de votre jeux")
            redirect_to @chat
        else
            render "chat/show", status: :unprocessable_entity
        end
    end

    # prêteur
    def accept
        # preteur redirection au profil et visuel de la notification dans sa ludo!! ==OK==
        authorize @booking
        @booking.update(status: :accepted)
        @booking.game.update(available: false)
        # Ajout du message dans le chat
        @system_message = @booking.chat.messages.create(chat_id: @booking.chat, user: @booking.game.user, content: "SYSTEM MESSAGE /=> Le preteur accepte le pret")
        # envoie d'une notice a la page de redirection
        flash[:notice] = "vous avez accepter de preter votre jeux"
        redirect_to owner_path # (@booking.game.user)
    end

    # prêteur
    def decline
        #annulation du booking
        # preteur redirection au profil et visuel de la notification dans sa ludo!! ==OK==
        authorize @booking
        @booking.update(status: :declined)
        # Ajout du message dans le chat
        @system_message = @booking.chat.messages.create(chat_id: @booking.chat, user: @booking.game.user, content: "SYSTEM MESSAGE /=> Le preteur refuse le pret")
        # envoie d'une notice a la page de redirection
        flash[:alert] = "vous n'avez accepter de preter votre jeux"
        redirect_to owner_path # (@booking.game.user)
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
