class RenameAdressToAddressInUsers < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :adress, :address
  end
end
