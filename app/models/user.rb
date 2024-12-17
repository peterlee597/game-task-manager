class User < ApplicationRecord
  has_many :tasks
  has_many :goals
  has_one :level

  after_create :create_level_if_needed

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable,
         omniauth_providers: [:google_oauth2]

  validates :username, presence: true, uniqueness: true

  def self.from_omniauth(auth)
    # Ensure the auth object is valid
    return nil unless auth && auth.provider && auth.uid && auth.info

    user = User.find_or_initialize_by(provider: auth.provider, uid: auth.uid)

    # Avoid updating fields if no valid info is found
    user.email = auth.info.email if auth.info.email.present?
    user.username = auth.info.name if auth.info.name.present?
    user.password = Devise.friendly_token[0, 20] if user.password.blank?
    user.calendar_id = auth.info.email if user.calendar_id.blank?

    # Set Google token and refresh token
    user.update(
      google_token: auth.credentials.token,  # Access token
      google_refresh_token: auth.credentials.refresh_token  # Refresh token
    )

    user.save!  # Ensure the user is saved after updating
    user
  end

  private

  def create_level_if_needed
    # Only create level if it doesn't already exist
    create_level(xp: 0, level: 1) unless level
  end
end