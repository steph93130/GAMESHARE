class AddNotifDismissedToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :notif_dismissed, :boolean, default: false, null: false
  end
end
