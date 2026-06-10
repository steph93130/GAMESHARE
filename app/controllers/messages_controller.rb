class MessagesController < ApplicationController
  def create
    @chat = Chat.find(params[:chat_id])
    @message = Message.new(message_params)
    authorize @message
    @message.chat = @chat
    @message.user = current_user
    if @message.save
      [@chat.user, @chat.game.user].each do |user|
        ActionCable.server.broadcast(
          "chat_#{@chat.id}_user_#{user.id}",
          render_to_string(partial: "messages/message", locals: { message: @message, mine: @message.user == user })
        )
      end
      recipient = @chat.user == current_user ? @chat.game.user : @chat.user
      broadcast_notifs_to(recipient)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @chat }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "new_message_container",
            partial: "messages/form",
            locals: {
              chat: @chat,
              message: @message
            }
          )
        end
        format.html { render "chats/show", status: :unprocessable_entity }
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
