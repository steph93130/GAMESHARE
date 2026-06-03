class RemoveForeignKeyUserIdToMessage < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :messages, :users
  end
end
