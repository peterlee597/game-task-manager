class User < ApplicationRecord
  has_many :tasks

    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable, :omniauthable, 
            omniauth_providers: [:google_oauth2]
          
    validates :username, presence: true, uniqueness: true


    def self.from_omniauth(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.email = auth.info.email
        user.username = auth.info.name
        user.password = Devise.friendly_token[0, 20]
      end
  end
end