class AddColumnLatToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :lat, :float
  end
end
