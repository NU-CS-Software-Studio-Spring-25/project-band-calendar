class AdminNotification < ApplicationRecord
  belongs_to :sent_by, class_name: "User"
  
  validates :subject, presence: true, length: { maximum: 255 }   
  validates :content, presence: true, length: { maximum: 2000 }
  validates :sent_by_id, presence: true

  # Serialize array fields as JSON
  serialize :event_ids, coder: JSON, type: Array
  serialize :user_ids, coder: JSON, type: Array

  validates :event_ids, length: { maximum: 5000 }   
  validates :user_ids, length: { maximum: 5000 }    

  validate :validate_array_lengths    # 精准限制 array 长度

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

  private

  def validate_array_lengths
    if event_ids.present? && event_ids.length > 1000
      errors.add(:event_ids, "is too long (maximum is 1000 items)")
    end
    if user_ids.present? && user_ids.length > 1000
      errors.add(:user_ids, "is too long (maximum is 1000 items)")
    end
  end
end
