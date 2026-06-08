class AvailableDefaultTrue < ActiveRecord::Migration[8.1]
  def change
    change_column_default :games, :available, from: nil, to: true
  end
end
