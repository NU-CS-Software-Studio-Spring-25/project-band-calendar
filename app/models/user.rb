class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :submitted_events, class_name: "Event", foreign_key: :submitted_by_id
  
  def admin?
    admin
  end
end
