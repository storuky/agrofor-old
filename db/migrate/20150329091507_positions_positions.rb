class PositionsPositions < ActiveRecord::Migration
  def change
    create_table :positions_positions do |t|
      t.integer :position_id

      t.integer :incoming_offer_id
      t.integer :outcoming_position_id
    end
  end
end
