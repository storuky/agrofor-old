class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :body
      t.references :correspondence, index: true, foreign_key: true
      t.integer :sender_id
      t.integer :recipient_id

      t.string :message_type

      t.timestamps null: false
    end
  end
end
