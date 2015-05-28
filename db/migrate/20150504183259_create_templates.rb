class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.integer :user_id
      t.index :user_id

      t.string :template_name
      t.string :title
      t.text :description
      
      t.integer :option_id
      t.integer :trade_type
      t.float :price
      t.float :price_discount
      t.float :weight
      t.float :weight_min
      t.integer :weight_dimension_id
      t.integer :currency_id
      t.string :city
      t.string :address
      t.float :lat
      t.float :lng

      t.timestamps null: false
    end
  end
end
