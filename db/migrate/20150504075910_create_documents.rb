class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :document
      t.integer :message_id
      t.timestamps null: false
    end
  end
end
