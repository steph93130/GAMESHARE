class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.string :title
      t.string :condition
      t.string :picture
      t.integer :rent_duration
      t.integer :age
      t.integer :player_number
      t.string :category
      t.text :description
      t.text :rules
      t.boolean :available
      t.decimal :deposit
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
