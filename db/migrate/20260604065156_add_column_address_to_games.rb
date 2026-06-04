class AddColumnAddressToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :address, :string
  end
end
