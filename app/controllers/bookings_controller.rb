class BookingsController < ApplicationController
  before_action :set_booking, only: [:accept, :decline, :validate, :deposit]

  def create
    @chat = Chat.find(params[:chat_id])
    @booking = Booking.new(game: @chat.game, user: current_user, chat: @chat )
    authorize @booking
    if @booking.save
      @system_message = @booking.chat.messages.create(chat_id: @booking.chat, user: current_user, content: "SYSTEM MESSAGE /=> #{current_user.username} demande le prêt de votre jeux")
      Turbo::StreamsChannel.broadcast_replace_to(
        "chat_#{@chat.id}_booking_actions",
        target: "booking_actions",
        partial: "chats/booking_actions",
        locals: { chat: @chat, booking: @booking, is_owner: true }
      )
      redirect_to @chat
    else
      render "chat/show", status: :unprocessable_entity
    end
  end

  # prêteur
  def accept
    authorize @booking
    @booking.update(status: :accepted)
    @booking.game.update(available: false)
    @system_message = @booking.chat.messages.create(
      chat_id: @booking.chat,
      user: @booking.game.user,
      content: "#{@booking.game.user.username} vient d'accepter votre demande de prêt. <a href='#{borrow_path}',
      class='borrow-link'>Voir mes emprunts</a>"
    )
    broadcast_message_to_chat(@booking.chat, @system_message)
    flash[:notice] = "#{@booking.game.user.username}, tu as accepté de prêter ton jeux #{@booking.game.title}."
    redirect_to owner_path
  end

  # prêteur
  def decline
    authorize @booking
    @booking.update(status: :declined)
    @system_message = @booking.chat.messages.create(
      chat_id: @booking.chat,
      user: @booking.game.user,
      content: "#{@booking.game.user.username} vient de refuser votre demande de prêt."
    )
    broadcast_message_to_chat(@booking.chat, @system_message)
    flash[:alert] = "#{@booking.game.user.username}, tu as refusé de prêter ton jeux #{@booking.game.title}."
    redirect_to owner_path
  end

  def deposit
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

  def broadcast_message_to_chat(chat, message)
    [chat.user, chat.game.user].each do |user|
      ActionCable.server.broadcast(
        "chat_#{chat.id}_user_#{user.id}",
        render_to_string(partial: "messages/message", locals: { message: message, mine: message.user == user })
      )
    end
  end
end
