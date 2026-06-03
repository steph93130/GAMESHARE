class BookingsController < ApplicationController

    
    def create
        raise
        @booking = Booking.new()
        authorize @booking
    end
end
