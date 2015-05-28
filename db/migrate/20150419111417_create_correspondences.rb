class CreateCorrespondences < ActiveRecord::Migration
  def change
    create_table :correspondences do |t|
      t.integer :sender_id
      t.integer :recipient_id

      t.integer :no_read_ids, array: true, default: []
      
      t.index :sender_id
      t.index :recipient_id
      
      t.integer :position_id
      t.integer :offer_id
      
      t.index :position_id
      t.index :offer_id

      t.string :correspondence_type
      t.index :correspondence_type

      t.integer :offerer_id
      t.index :offerer_id

      t.string :status

      t.timestamps null: false
    end
    
  end
end
