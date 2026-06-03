class MessagesController < ApplicationController
  def create
    @message = Message.new(message_params)
    authorize @message

  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
