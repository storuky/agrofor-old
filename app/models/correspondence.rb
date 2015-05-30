class Correspondence < ActiveRecord::Base

  include AASM

  aasm :column => :status do
    state :new_offer, :initial => true
    state :position_agree
    state :offer_agree
    state :position_complete
    state :offer_complete
    state :stopped

    event :run_new_offer do
      transitions :to => :new_offer, :from => :stopped
    end

    event :run_position_agree do
      transitions :to => :position_agree, :from => [:new_offer]
    end

    event :run_offer_agree do
      transitions :to => :offer_agree, :from => [:position_agree]
    end

    event :run_position_complete do
      transitions :to => :position_complete, :from => [:offer_agree]
    end

    event :run_offer_complete do
      transitions :to => :offer_complete, :from => [:position_complete]
    end

    event :stop do
      transitions :to => :stopped, :from => [:new_offer, :position_agree]
    end
  end

  after_create :ws

  has_many :messages, dependent: :destroy
  has_many :unread_messages, dependent: :destroy

  has_and_belongs_to_many :users
  has_and_belongs_to_many :positions
  belongs_to :position, class_name: "Position"
  belongs_to :offer, class_name: "Position"

  scope :new_messages_count_for_positions, -> (user) { joins('JOIN unread_messages ON correspondences.id = unread_messages.correspondence_id').where("unread_messages.user_id = ? AND NOT position_id IS null", user.id).group(:id).count }
  scope :new_messages_count_for_users, -> (user) { joins('JOIN unread_messages ON correspondences.id = unread_messages.correspondence_id').where("unread_messages.user_id = ? AND position_id IS null", user.id).group(:id).count }

  def read_all! user
    UnreadMessage.delete_all(correspondence_id: id, user_id: user.id)
  end
 
  def self.create_between_positions position, offer
    unless Correspondence.between_users position.user, offer.user
      Correspondence.create_between_users position.user, offer.user
    end

    @correspondence = Correspondence.new correspondence_type: 'positions', position_id: position.id, offer_id: offer.id, recipient_id: position.user_id, sender_id: offer.user_id
    @correspondence.offerer_id = offer.user_id
    @correspondence.users = [offer.user, position.user]
    @correspondence.positions = [position, offer]
    @correspondence.save
    @correspondence
  end

  def self.create_between_users first_user, second_user 
    @correspondence = Correspondence.new correspondence_type: 'users', recipient_id: first_user.id, sender_id: second_user.id
    @correspondence.users = [first_user, second_user]
    @correspondence.save
    @correspondence
  end

  def self.between_positions position_id, offer_id
    where("(position_id = ? AND offer_id = ?) OR (position_id = ? AND offer_id = ?)", position_id, offer_id, offer_id, position_id).first
  end

  def self.between_users first_user, second_user
    where("(recipient_id = ? AND sender_id = ?) OR (recipient_id = ? AND sender_id = ?)", first_user.id, second_user.id, second_user.id, first_user.id).first
  end

  def user
    self.users.first.info
  end

  private

    def ws
      correspondence = self.as_json(include: :positions)
      correspondence["user"] = User.where(id: sender_id).first.info
      PrivatePub.publish_to "/stream/#{recipient_id}", {type: "new_correspondence", correspondence: correspondence}
    end

end
