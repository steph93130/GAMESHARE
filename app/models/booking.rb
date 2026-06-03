class Booking < ApplicationRecord
  belongs_to :game
  belongs_to :user
  belongs_to :chat
  enum status: { pending: 0, enprunting: 1, reporting: 2, close: 3 }

end
