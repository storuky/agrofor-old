class CreateCorrespondencesPositions < ActiveRecord::Migration
  def change
    create_table :correspondences_positions do |t|
      t.integer :position_id
      t.integer :correspondence_id
    end
  end
end
