class BookingsController < ApplicationController
  def index
    @bookings = policy_scope(Booking)
    @user = current_user
    @incoming_chats = Chat.joins(:game).where(games: { user_id: current_user.id })
  end

  def new
    @booking = Booking.new
    authorize @booking
  end

  def create
    @chat = Chat.find(params[:chat_id])
    @booking = Booking.new(game: @chat.game, user: current_user, chat: @chat)
    authorize @booking
    if @booking.save
      redirect_to @chat
    else
      render "chat/show", status: :unprocessable_entity
    end
  end

  def edit
    @booking = Booking.find(params[:id])
    authorize @booking
  end

  def update
    @booking = Booking.find(params[:id])
    raise
    authorize @booking
    @booking.update(status: :enprunting)
  end
end
