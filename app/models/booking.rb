class Booking < ApplicationRecord
  belongs_to :game
  belongs_to :user
  belongs_to :chat
end
