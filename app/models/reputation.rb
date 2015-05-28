class Reputation < ActiveRecord::Base
  belongs_to :position
  belongs_to :user
  belongs_to :sender, foreign_key: 'sender_id', class_name: 'User'
end
