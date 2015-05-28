class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :photo
      t.integer :position_id
      t.timestamps null: false
    end
  end
end
