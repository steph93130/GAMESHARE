class Chat < ApplicationRecord
  belongs_to :game
  belongs_to :user
  has_many :messages, dependent: :destroy
  # Fait en sorte de n'avoir n'avoir qu'un seul booking
  has_one :booking
end
