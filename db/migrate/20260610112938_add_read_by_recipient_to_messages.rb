class AddReadByRecipientToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :read_by_recipient, :boolean, default: false, null: false
  end
end
