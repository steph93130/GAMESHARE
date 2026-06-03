class AddColumnContentToMessage < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :content, :string
  end
end
