class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :positions

  has_and_belongs_to_many :favorites, association_foreign_key: 'favorite_id', class_name: 'Position'
  has_many :templates
  mount_uploader :avatar, AvatarUploader

  has_and_belongs_to_many :correspondences

  belongs_to :currency

  has_many :reputations

  # def correspondences
  #   Correspondence.where("correspondences.sender_id =? OR correspondences.recipient_id =?",id,id)
  # end

  def new_messages_count
    UnreadMessage.where(user_id: id).count
  end

  def read_all_messages!
    UnreadMessage.delete_all(user_id: id)
  end

  def positive_count
    self.reputations.where(reputation_type: 'positive').count
  end

  def negative_count
    self.reputations.where(reputation_type: 'negative').count
  end

  def info
    as_json(only: [:id, :locale, :sms_notify, :email_notify, :email, :name, :city, :address, :lat, :lng, :company, :avatar, :phone, :additional], include: {:currency => {methods: :title}}, methods: [:favorite_ids, :online])
  end

  def online
    updated_at > 10.minutes.ago
  end

end
