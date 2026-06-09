class Booking < ApplicationRecord
  enum :status, { pending: 0, accepted: 1, validated: 2, returned: 3, closed: 4, declined: 5 }, default: 0

  belongs_to :game
  belongs_to :user
  belongs_to :chat

  validates :status, presence: true
end
