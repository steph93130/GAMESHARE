class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :games, dependent: :destroy
  has_many :chats, dependent: :destroy

  geocoded_by :address, latitude: :lat, longitude: :lng
  after_validation :geocode, if: :will_save_change_to_address?
  after_validation :cascade_location_to_games, if: :will_save_change_to_address?

  def geocode_address
    result = Geocoder.search(address).first
    return unless result

    update_columns(lat: result.latitude, lng: result.longitude)
  end

  private

  def cascade_location_to_games
    games.update_all(lat: lat, lng: lng)
  end
end
