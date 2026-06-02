class AddColumnToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :username, :string, default: "", null: false
    add_column :users, :rating, :integer
    add_column :users, :city, :string, default: "", null: false
    add_column :users, :postalcode, :integer, default: 0, null: false
  end
end
