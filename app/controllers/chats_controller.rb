class ChatsController < ApplicationController
  def create
    @game = Game.find(params[:game_id])
    @chat = Chat.new(user: current_user, game: @game)
    authorize @chat
    if @chat.save
      Turbo::StreamsChannel.broadcast_replace_to(
        "game_#{@game.id}_new_chat",
        target: "inline_chat_placeholder",
        partial: "chats/inline",
        locals: { chat: @chat, is_owner: true, other_user: @chat.user }
      )
      redirect_to game_path(@game, query: params[:query])
    else
      render "games/show", status: :unprocessable_entity
    end
  end

  def show
    @chat = Chat.find(params[:id])
    @game = @chat.game
    @borrower = @chat.user
    @owner = @game.user
    @role = current_user == @borrower ? "borrower" : "owner"
    @other_user = @role == "borrower" ? @owner : @borrower
    @message = Message.new(chat: @chat)
    @messages = @chat.messages
    unread = @chat.messages.where(read_by_recipient: false).where.not(user: current_user)
    if unread.any?
      unread.update_all(read_by_recipient: true)
      broadcast_notifs_to(current_user)
    end
  end

  def mark_read
    @chat = Chat.find(params[:id])
    @chat.messages.where(read_by_recipient: false).where.not(user: current_user).update_all(read_by_recipient: true)
    broadcast_notifs_to(current_user)
    head :ok
  end
end
