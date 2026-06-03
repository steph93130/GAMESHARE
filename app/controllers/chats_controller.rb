class ChatsController < ApplicationController
  def create
    @game = Game.find(params[:game_id])
    @chat = Chat.new(user: current_user, game: @game)
    authorize @chat
    if @chat.save
      # Rails.logger.info "Chat bien créé avec l'ID #{@chat.id}."
      redirect_to @chat
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
  end
end
