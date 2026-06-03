class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.boolean :report
      t.integer :status
      t.float :rating_user
      t.float :rating_preteur
      t.references :game, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :chat, null: false, foreign_key: true

      t.timestamps
    end
  end
end
