class BookingsController < ApplicationController
  before_action :set_booking,
                only: [:accept, :decline, :validate, :deposit, :cancel, :dismiss_notif, :close, :give_back, :returned,
                       :rate]

  # l'emprunteur crée le booking passage a submiting affichage chez le preteur
  def create
    @chat = Chat.find(params[:chat_id])
    @booking = Booking.new(game: @chat.game, user: current_user, chat: @chat, status: :submited)
    authorize @booking
    if @booking.save
      @system_message = @booking.chat.messages.create(
        chat_id: @booking.chat,
        user: current_user,
        content: "BORROW_REQUEST|#{current_user.username}",
        read_by_recipient: true
      )
      broadcast_message_to_chat(@booking.chat, @system_message)
      broadcast_notifs_to(@chat.game.user)
      Turbo::StreamsChannel.broadcast_replace_to(
        "chat_#{@chat.id}_booking_actions",
        target: "booking_actions",
        partial: "chats/booking_actions",
        locals: { chat: @chat, booking: @booking, is_owner: true }
      )
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "booking_actions",
            partial: "chats/booking_actions",
            locals: { chat: @chat, booking: @booking, is_owner: false }
          )
        end
        format.html { redirect_back_or_to @chat }
      end
    else
      render "chat/show", status: :unprocessable_entity
    end
  end

  # prêteur accepte le prêt
  def accept
    authorize @booking
    @booking.update(status: :accepted, notif_dismissed_borrower: false, notif_dismissed_lender: false)
    @booking.game.update(available: false)
    @system_message = @booking.chat.messages.create(
      chat_id: @booking.chat,
      user: @booking.game.user,
      content: "#{@booking.game.user.username} vient d'accepter votre demande de prêt. " \
               "<a href=\"#{borrow_path}\" style=\"color: white; text-decoration: underline;\">Voir mes emprunts</a>",
      read_by_recipient: true
    )
    broadcast_message_to_chat(@booking.chat, @system_message)
    Turbo::StreamsChannel.broadcast_replace_to(
      "chat_#{@booking.chat.id}_booking_actions_borrower",
      target: "booking_actions",
      partial: "chats/booking_actions",
      locals: { chat: @booking.chat, booking: @booking, is_owner: false }
    )
    broadcast_bookings_to(@booking.user)
    broadcast_notifs_to(@booking.user)
    broadcast_notifs_to(@booking.game.user)
    redirect_to borrow_path
  end

  # prêteur refuse le prêt
  def decline
    authorize @booking
    @booking.update(status: :declined, notif_dismissed_borrower: false, notif_dismissed_lender: false)
    Turbo::StreamsChannel.broadcast_remove_to(
      "game_#{@booking.game.id}_inline_chat",
      target: "inline_chat_container"
    )
    @system_message = @booking.chat.messages.create(
      chat_id: @booking.chat,
      user: @booking.game.user,
      content: "#{@booking.game.user.username} vient de refuser votre demande de prêt.",
      read_by_recipient: true
    )
    broadcast_message_to_chat(@booking.chat, @system_message)
    Turbo::StreamsChannel.broadcast_replace_to(
      "chat_#{@booking.chat.id}_booking_actions_borrower",
      target: "booking_actions",
      partial: "chats/booking_actions",
      locals: { chat: @booking.chat, booking: @booking, is_owner: false }
    )
    broadcast_bookings_to(@booking.user)
    broadcast_notifs_to(@booking.user)
    broadcast_notifs_to(@booking.game.user)
    redirect_to borrow_path
  end

  # emprunteur accede pages de caution
  def deposit
    # raise
    authorize @booking
  end

  # emprunteur valide si accept
  def validate
    authorize @booking
    @booking.update(status: :validated, notif_dismissed_borrower: false, notif_dismissed_lender: false)
    @booking.game.update(available: false)
    broadcast_bookings_to(@booking.game.user)
    broadcast_notifs_to(@booking.game.user)
    broadcast_notifs_to(@booking.user)
    redirect_to borrow_path
  end

  # dismiss d'une notification
  def dismiss_notif
    authorize @booking
    if current_user == @booking.user
      @booking.update(notif_dismissed_borrower: true)
    else
      @booking.update(notif_dismissed_lender: true)
    end
    broadcast_notifs_to(current_user)
    params[:after] == "borrow" ? redirect_to(borrow_path) : head(:ok)
  end

  # emprunteur annule le paiement de la caution
  def cancel
    authorize @booking
    @booking.update(status: :cancelled, notif_dismissed_borrower: false, notif_dismissed_lender: false)
    @booking.game.update(available: true)
    Turbo::StreamsChannel.broadcast_remove_to(
      "game_#{@booking.game.id}_inline_chat",
      target: "inline_chat_container"
    )
    @system_message = @booking.chat.messages.create(
      chat_id: @booking.chat,
      user: @booking.user,
      content: "#{@booking.user.username} a annulé l'emprunt.",
      read_by_recipient: true
    )
    broadcast_message_to_chat(@booking.chat, @system_message)
    broadcast_notifs_to(@booking.game.user)
    broadcast_notifs_to(@booking.user)
    redirect_to borrow_path
  end

  # prêteur valide le retour
  def returned
    authorize @booking
    @booking.update(status: :returned, notif_dismissed_lender: false, notif_dismissed_borrower: false)
    broadcast_bookings_to(@booking.user)
    broadcast_notifs_to(@booking.user)
    broadcast_notifs_to(@booking.game.user)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "rating_modal_container",
          partial: "shared/modal_rating",
          locals: {
            booking: @booking,
            rated_user: @booking.user,
            rated_role: "user"
          }
        )
      end
      format.html { redirect_to borrow_path }
    end
  end

  # emprunteur récupère sa caution
  def give_back
    authorize @booking
  end

  # Apres give back clodure le booking  par l'enprunteur
  def close
    authorize @booking
    @booking.update(status: :closed, notif_dismissed_borrower: false)
    @booking.game.update(available: true)
    broadcast_bookings_to(@booking.game.user)
    broadcast_games_to(@booking.game.user)
    broadcast_notifs_to(@booking.user)
    Turbo::StreamsChannel.broadcast_remove_to(
      "game_#{@booking.game.id}_inline_chat",
      target: "inline_chat_container"
    )
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "rating_modal_container",
          partial: "shared/modal_rating",
          locals: {
            booking: @booking,
            rated_user: @booking.game.user,
            rated_role: "preteur"
          }
        )
      end
      format.html { redirect_to borrow_path }
    end
  end

  # notation après un échange
  def rate
    authorize @booking
    score = params[:score].to_f.clamp(0.0, 5.0)
    case params[:rated_role]
    when "user"
      @booking.update(rating_user: score)
      update_user_rating(@booking.user)
    when "preteur"
      @booking.update(rating_preteur: score)
      update_user_rating(@booking.game.user)
    end
    redirect_path = params[:rated_role] == "user" ? owner_path : borrow_path
    broadcast_flash_to(current_user, "Merci pour votre évaluation !")
    redirect_to redirect_path
  end

  private

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def broadcast_games_to(user)
    inner = render_to_string(
      partial: "profiles/game-card-owner",
      locals: { games: user.games.reload }
    )
    Turbo::StreamsChannel.broadcast_replace_to(
      "user_#{user.id}_games",
      target: "owner_games",
      html: "<div id=\"owner_games\" class=\"game-rules text-start\">#{inner}</div>"
    )
  end

  def broadcast_bookings_to(user)
    Turbo::StreamsChannel.broadcast_replace_to(
      "user_#{user.id}_bookings",
      target: "booking_management",
      html: render_to_string(
        partial: "profiles/booking_management",
        locals: {
          borrow: borrow_status_for(user),
          owner: owner_status_for(user),
          viewer: user
        }
      )
    )
  end

  def borrow_status_for(user)
    statuses = { submited: [], accepted: [], validated: [], returned: [], closed: [] }
    user.chats.includes(:booking).each do |chat|
      b = chat.booking
      next unless b

      key = b.status.to_sym
      statuses[key] << b if statuses.key?(key)
    end
    statuses
  end

  def owner_status_for(user)
    statuses = { submited: [], accepted: [], validated: [], returned: [], closed: [] }
    user.games.includes(chats: :booking).each do |game|
      game.chats.each do |chat|
        b = chat.booking
        next unless b

        key = b.status.to_sym
        statuses[key] << b if statuses.key?(key)
      end
    end
    statuses
  end

  def update_user_rating(user)
    borrower_scores = Booking.where(user: user).where.not(rating_user: nil).pluck(:rating_user)
    lender_scores = Booking.joins(:game)
                           .where(games: { user_id: user.id })
                           .where.not(rating_preteur: nil)
                           .pluck(:rating_preteur)
    all_scores = borrower_scores + lender_scores
    return if all_scores.empty?

    user.update(rating: all_scores.sum / all_scores.size.to_f)
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
