class MessagesController < ApplicationController
  def create

    @chat = Chat.find(params[:chat_id])
    @message = Message.new(message_params)
    authorize @message
    @message.chat = @chat
    @message.user = current_user

    if @message.save
      build_conversation_history
      respond_to do |format|
        format.turbo_stream # renders `app/views/messages/create.turbo_stream.erb`
        format.html { redirect_to @chat }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.update("new_message_container",
                                                                        partial: "messages/form",
                                                                        locals: {
                                                                          chat: @chat,
                                                                          message: @message })
                            }
        format.html { render "chats/show", status: :unprocessable_entity }
      end
      # render :index, status: :unprocessable_entity
    end
  end

  private

  def build_conversation_history
    @chat.messages.each do |message|
      @message.add_message(message)
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end

end
