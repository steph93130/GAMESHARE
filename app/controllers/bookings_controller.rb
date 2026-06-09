class BookingsController < ApplicationController
    before_action :set_booking, only: [:accept, :decline, :validate, :deposit, :close, :give_back, :returned]

  def create
    @chat = Chat.find(params[:chat_id])
    @booking = Booking.new(game: @chat.game, user: current_user, chat: @chat )
    authorize @booking
    if @booking.save
      @system_message = @booking.chat.messages.create(chat_id: @booking.chat, user: current_user, content: "BORROW_REQUEST|#{current_user.username}")
      broadcast_message_to_chat(@booking.chat, @system_message)
      Turbo::StreamsChannel.broadcast_replace_to(
        "chat_#{@chat.id}_booking_actions",
        target: "booking_actions",
        partial: "chats/booking_actions",
        locals: { chat: @chat, booking: @booking, is_owner: true }
      )
      redirect_back_or_to @chat
    else
      render "chat/show", status: :unprocessable_entity
    end
  end

    # prêteur accepte le prêt
    def accept
        authorize @booking
        @booking.update(status: :accepted)
        @booking.game.update(available: false)
        @system_message = @booking.chat.messages.create(
            chat_id: @booking.chat,
            user: @booking.game.user,
            content: "#{@booking.game.user.username} vient d'accepter votre demande de prêt. <a href=\"#{borrow_path}\" style=\"color: white; text-decoration: underline;\">Voir mes emprunts</a>"
        )
        broadcast_message_to_chat(@booking.chat, @system_message)
        flash[:notice] = "#{@booking.game.user.username}, tu as accepté de prêter ton jeux #{@booking.game.title}."
        redirect_to owner_path
    end

    # prêteur refuse le prêt
    def decline
        authorize @booking
        @booking.update(status: :declined)
        Turbo::StreamsChannel.broadcast_remove_to(
          "game_#{@booking.game.id}_inline_chat",
          target: "inline_chat_container"
        )
        @system_message = @booking.chat.messages.create(
            chat_id: @booking.chat,
            user: @booking.game.user,
            content: "#{@booking.game.user.username} vient de refuser votre demande de prêt."
        )
        broadcast_message_to_chat(@booking.chat, @system_message)
        flash[:alert] = "#{@booking.game.user.username}, tu as refusé de prêter ton jeux #{@booking.game.title}."
        redirect_to owner_path
    end
    
    # emprunteur accede pages de caution
    def deposit
        # raise
        authorize @booking
    end
    # emprunteur valide si accept
    def validate
        authorize @booking
        @booking.update(status: :validated)
        @booking.game.update(available: false)
        redirect_to borrow_path
    end
    
    
    # prêteur valide le retour
    def returned
        authorize @booking
        @booking.update(status: :returned)
        redirect_to owner_path
    end

    # emprunteur récupère sa caution
    def give_back
        authorize @booking
    end

    # Apres give back clodure le booking 
    def close
        authorize @booking
        @booking.update(status: :closed)
        @booking.game.update(available: true)
        Turbo::StreamsChannel.broadcast_remove_to(
          "game_#{@booking.game.id}_inline_chat",
          target: "inline_chat_container"
        )
        redirect_to borrow_path
    end


    private

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def broadcast_message_to_chat(chat, message)
    [chat.user, chat.game.user].each do |user|
      ActionCable.server.broadcast(
        "chat_#{chat.id}_user_#{user.id}",
        render_to_string(partial: "messages/message", locals: { message: message, mine: message.user == user })
      )
    end
  end
end
