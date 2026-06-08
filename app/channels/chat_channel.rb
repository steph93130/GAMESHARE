class ChatChannel < ApplicationCable::Channel
  def subscribed
    chat = Chat.find(params[:id])
    stream_from "chat_#{chat.id}_user_#{current_user.id}"
  end
end
