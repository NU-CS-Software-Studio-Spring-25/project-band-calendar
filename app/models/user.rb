# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  admin                  :boolean          default(false)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

# Represents an application user with authentication and authorization features.
#
# Uses Devise for authentication.
class User < ApplicationRecord
  # Devise modules for user authentication.
  # Available modules: :confirmable, :lockable, :timeoutable, :trackable, :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  # A user can submit many events.
  has_many :submitted_events, class_name: "Event", foreign_key: :submitted_by_id

  # Checks if the user has admin privileges.
  #
  # @return [Boolean] true if the user is an admin, false otherwise
  def admin?
    admin
  end
end
