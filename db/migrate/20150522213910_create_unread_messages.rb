class CreateUnreadMessages < ActiveRecord::Migration
  def change
    create_table :unread_messages do |t|
      t.integer :message_id
      t.integer :user_id
      t.integer :correspondence_id

      t.timestamps null: false
    end
  end
end
