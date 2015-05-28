class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.boolean :delta, :default => true, :null => false
      t.string :status

      t.integer :position_id 
      t.index :position_id 

      t.string :title
      t.text :description

      t.integer :user_id
      t.index :user_id

      t.integer :option_id
      t.index :option_id

      t.boolean :template
      t.string :template

      t.integer :trade_type
      t.index :trade_type

      t.integer :currency_id

      t.float :price
      
      t.float :price_etalon
      t.index :price_etalon
      t.float :price_discount, :default => 0, :null => false

      t.float :weight
      t.float :weight_min, :default => 0, :null => false

      t.float :weight_etalon
      t.index :weight_etalon

      t.float :weight_min_etalon, :default => 0, :null => false
      t.index :weight_min_etalon

      t.integer :weight_dimension_id
      t.index :weight_dimension_id

      t.integer :deal_with_id
      t.index :deal_with_id

      t.boolean :is_offer, default: false, null: false
      t.index :is_offer

      t.string :index_field

      t.string :city
      t.index :city
      
      t.string :address
      t.float :lat
      t.float :lng

      t.timestamps
    end

    # execute <<-SQL
    #       CREATE INDEX position_price_etalon_index ON positions ((price->>'etalon'))
    #     SQL
    # execute <<-SQL
    #       CREATE INDEX position_weight_etalon_index ON positions ((weight->>'etalon'))
    #     SQL

  end
end
