class PositionsUsers < ActiveRecord::Migration
  def change
    create_table :positions_users do |t|
      t.integer :user_id
      t.integer :position_id
    end
  end
end
