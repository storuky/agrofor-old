class Message < ActiveRecord::Base
  after_create :message_create

  has_one :document
  
  belongs_to :correspondence, touch: true
  belongs_to :recipient, class_name: 'User', foreign_key: 'recipient_id'
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  
  validates_presence_of :correspondence_id, :recipient_id, :sender_id
  validate :message_validate

  QUERY = {
        :include => {
          sender: {
            only: [:name, :id, :avatar]
          },
          document: {
            only: [:document, :file_name]
          }
        }
      }

  private
    def message_create
      UnreadMessage.create(user_id: recipient_id, correspondence_id: correspondence_id, message_id: id)
      WebsocketRails.users[recipient_id].send_message :new_message, {status: correspondence.status, message: self.as_json(Message::QUERY)}, :namespace => :correspondences
      WebsocketRails.users[sender_id].send_message :new_message, {status: correspondence.status, message: self.as_json(Message::QUERY)}, :namespace => :correspondences
    end

    def message_validate
      if self.body.nil? && !self.message_type
        errors.add(:body, I18n.t("message.notice.empty"))
      end
    end
end