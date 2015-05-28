class CreateWeightDimensions < ActiveRecord::Migration
  def change
    create_table :weight_dimensions do |t|
      t.string :name
      t.float :convert

      t.timestamps null: false
    end
  end
end
