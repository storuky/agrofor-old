class CreateOption < ActiveRecord::Migration
  def change
    create_table :options do |t|
      t.string :title
      t.integer :category_id
      t.index :category_id
    end
  end
end
