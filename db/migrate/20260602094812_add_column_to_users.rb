class AddColumnToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :username, :string, default: "", null: false
    add_column :users, :rating, :integer
  end
end
