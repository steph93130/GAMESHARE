class MessagesController < ApplicationController
  def create

  end
  private

  def params_message
    params.require(:message).permit(:)
  end
end
