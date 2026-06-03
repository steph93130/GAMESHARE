class AddIndexToGamesLatLng < ActiveRecord::Migration[8.1]
  def change
    add_index :games, [:lat, :lng]
  end
end
