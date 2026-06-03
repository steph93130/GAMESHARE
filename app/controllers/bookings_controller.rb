class BookingsController < ApplicationController

    
    def new
        @booking = Booking.new()
        authorize @booking
    end

    def create
        @game = Game.find(params[:game_id])
        @chat = Chat.find(params[:chat_id])
        @booking = Booking.new(game: @game, user: current_user, chat: @chat )
        authorize @booking
        if @booking.save
            redirect_to edit_game_chat_booking_path(@game, @chat, @booking)
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
        authorize @booking
    end
end
