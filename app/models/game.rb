class Game < ApplicationRecord
  belongs_to :user
  has_many :chats, dependent: :destroy
  has_many :bookings, dependent: :destroy

  validates :age,           presence: true
  validates :category,      presence: true
  validates :condition,     presence: true
  validates :deposit,       presence: true
  validates :player_number, presence: true
  validates :rent_duration, presence: true
  validates :title,         presence: true

  geocoded_by :address, latitude: :lat, longitude: :lng
  before_validation :inherit_user_address
  after_validation :geocode, if: :will_save_change_to_address?

  has_one_attached :picture

  private

  def inherit_user_address
    self.address = user.address
  end
end
