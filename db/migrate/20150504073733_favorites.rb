class Favorites < ActiveRecord::Migration
  def change
    change_table :positions_users do |t|
      t.integer :favorite_id
    end
  end
end
