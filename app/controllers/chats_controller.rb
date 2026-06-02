class ChatsController < ApplicationController
  def create
    raise

    @chat = Chat.new(user: current_user, game: game_id)
  end
end
