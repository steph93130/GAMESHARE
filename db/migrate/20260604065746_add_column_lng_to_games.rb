class AddColumnLngToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :lng, :float
  end
end
