class AddColumnLgtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :lgt, :float
  end
end
