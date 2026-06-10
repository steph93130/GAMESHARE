class Booking < ApplicationRecord
  enum :status, { pending: 0, submited: 1, accepted: 2, validated: 3, returned: 4, closed: 5, declined: 6, cancelled: 7 }, default: 0

  belongs_to :game
  belongs_to :user
  belongs_to :chat

  validates :status, presence: true
end
