class Game < ApplicationRecord
  belongs_to :user
  has_many :chats, dependent: :destroy

  before_create :inherit_user_location

  private

  def inherit_user_location
    self.lat = user.lat
    self.lng = user.lng
  end
end
