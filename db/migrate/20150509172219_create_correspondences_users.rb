class CreateCorrespondencesUsers < ActiveRecord::Migration
  def change
    create_table :correspondences_users do |t|
      t.integer :correspondence_id
      t.integer :user_id
    end
  end
end
