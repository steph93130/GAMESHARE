class ChatsController < ApplicationController
  def create

    @game = Game.find(params[:game_id])
    @chat = Chat.new(user: current_user, game: @game)
    # authorize @chat
    if @chat.save
      Rails.logger.info "Chat bien créé avec l'ID #{@chat.id}."
      redirect_to game_path(@game)
    else
      render "games/show", status: :unprocessable_entity
    end

  end
end
