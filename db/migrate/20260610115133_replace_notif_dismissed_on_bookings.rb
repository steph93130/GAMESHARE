class ReplaceNotifDismissedOnBookings < ActiveRecord::Migration[8.1]
  def change
    remove_column :bookings, :notif_dismissed, :boolean
    add_column :bookings, :notif_dismissed_borrower, :boolean, default: false, null: false
    add_column :bookings, :notif_dismissed_lender,   :boolean, default: false, null: false
  end
end
