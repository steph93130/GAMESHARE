class RemovePictureFromGames < ActiveRecord::Migration[8.1]
  def change
    remove_column :games, :picture, :string
  end
end
