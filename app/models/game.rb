class Game < ApplicationRecord
  belongs_to :user
  has_many :chats, dependent: :destroy

  geocoded_by :address, latitude: :lat, longitude: :lng
  before_validation :inherit_user_address
  after_validation :geocode, if: :will_save_change_to_address?

  has_one_attached :picture

  private

  def inherit_user_address
    self.address = user.address
  end
end
