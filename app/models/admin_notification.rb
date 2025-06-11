class AdminNotification < ApplicationRecord
  belongs_to :sent_by, class_name: "User"
  
  validates :subject, :content, presence: true
  validates :sent_by_id, presence: true
  
  # Serialize array fields as JSON
  serialize :event_ids, coder: JSON, type: Array
  serialize :user_ids, coder: JSON, type: Array
  
  scope :recent, -> { order(sent_at: :desc) }
  
  def events
    Event.where(id: event_ids) if event_ids.present?
  end
  
  def users
    User.where(id: user_ids) if user_ids.present?
  end
  
  def sent?
    sent_at.present?
  end
  
  def recipient_count
    user_ids&.length || 0
  end
  
  def event_count
    event_ids&.length || 0
  end
end
