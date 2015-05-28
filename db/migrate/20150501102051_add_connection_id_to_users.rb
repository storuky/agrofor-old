class AddConnectionIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :connection_id, :string
  end
end
