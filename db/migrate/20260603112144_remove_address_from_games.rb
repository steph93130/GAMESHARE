class RemoveAdressFromGames < ActiveRecord::Migration[8.1]
  def change
    remove_column :games, :adress, :string
  end
end
