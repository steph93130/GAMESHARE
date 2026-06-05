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
        @params_message_accepted = {chat_id: @booking.chat, user: @booking.game.user, content: "#{@booking.game.user.username} vient d'accepter votre demade de prêt Rendez-vous sur ton profile pour validation."}
        @system_message = @booking.chat.messages.create(@params_message_accepted)
        # envoie d'une notice a la page de redirection
        flash[:notice] = "#{@booking.game.user.username}, tu as accepté de prêter ton jeux #{@booking.game.title}."
        redirect_to owner_path # (@booking.game.user)
    end

    # prêteur
    def decline
        #annulation du booking
        # preteur redirection au profil et visuel de la notification dans sa ludo!! ==OK==
        authorize @booking
        @booking.update(status: :declined)
        # Ajout du message dans le chat
        @params_message_rejected = {chat_id: @booking.chat, user: @booking.game.user, content: "#{@booking.game.user.username} vient de refuser votre demade de prêt."}
        @system_message = @booking.chat.messages.create(@params_message_rejected)
        # envoie d'une notice a la page de redirection
        flash[:alert] = "#{@booking.game.user.username}, tu as refusé de prêter ton jeux #{@booking.game.title}."
        redirect_to owner_path # (@booking.game.user)
    end
    def deposit
        # raise
        authorize @booking

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
