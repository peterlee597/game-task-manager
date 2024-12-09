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
    user = User.find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    user.email = auth.info.email
    user.username = auth.info.name
    user.password = Devise.friendly_token[0, 20]

    user.update(
      google_token: auth.credentials.token,  # Access token
      google_refresh_token: auth.credentials.refresh_token # Refresh token
    )
    user
  end

  def refresh_google_token
    return unless google_refresh_token.present?

    client = Signet::OAuth2::Client.new(
      Rails.application.credentials.dig(:google, :client_id),
      Rails.application.credentials.dig(:google, :client_secret_id),
      refresh_token: google_refresh_token,
      token_credential_uri: 'https://oauth2.googleapis.com/token'
    )

    # Fetch new access token
    response = client.fetch_access_token!

    # Save the new token in the database
    update(google_token: response['access_token'])
  end

  private

  def create_level_if_needed
    # Only create level if it doesn't already exist
    create_level(xp: 0, level: 1) unless level
  end
end
