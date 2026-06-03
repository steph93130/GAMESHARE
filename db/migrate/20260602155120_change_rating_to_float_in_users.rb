class ChangeRatingToFloatInUsers < ActiveRecord::Migration[8.1]
  def change
    change_column :users, :rating, :float
  end
end
