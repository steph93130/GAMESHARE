class AddColumnLgtToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :lgt, :float
  end
end
