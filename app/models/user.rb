class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :games, dependent: :destroy
  has_many :chats, dependent: :destroy
  has_many :messages, dependent: :destroy

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :email,    presence: true, uniqueness: { case_sensitive: false }
  validates :address,  presence: true
  validates :password, length: { minimum: 6 }, allow_nil: true

  after_validation :cascade_location_to_games, if: :will_save_change_to_address?

  private

  def cascade_location_to_games
    games.each { |game| game.update(address: address) }
    # games.update_all(address: address)
  end
end
