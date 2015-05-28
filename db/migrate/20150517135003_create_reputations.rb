class CreateReputations < ActiveRecord::Migration
  def change
    create_table :reputations do |t|
      t.string :title
      t.text :description

      t.integer :position_id
      t.index :position_id

      t.integer :user_id
      t.index :user_id

      t.integer :sender_id
      t.index :sender_id
      
      t.string :reputation_type

      t.timestamps null: false
    end
  end
end
