class User < ApplicationRecord
  devise :registerable,
         # :database_authenticatable,
         # :recoverable, # Removed as we use magic links instead
         :rememberable,
         :validatable,
         :confirmable,
         :lockable, :timeoutable, :trackable,
         :magic_link_authenticatable,
         :omniauthable,
         omniauth_providers: [
           :google_oauth2,
           :entra_id
         ]

  has_many :user_profiles, dependent: :destroy
  has_many :profiles, through: :user_profiles
  belongs_to :main_profile, class_name: 'Profile', dependent: :destroy

  validates :main_profile, presence: true
  validates_associated :main_profile

  accepts_nested_attributes_for :main_profile

  attr_accessor :pending_vote_token

  def handle
    main_profile.handle
  end

  def self.from_google(u)
    u = find_or_initialize_by(email: u[:email])
    u.uid = u[:uid]
    u.provider = 'google'
    u.main_profile ||= Profile.new
    u.confirm
    u.save!
    u
  end

  def self.from_microsoft(u)
    u = find_or_initialize_by(email: u[:email])
    u.uid = u[:uid]
    u.provider = 'microsoft'
    u.main_profile ||= Profile.new
    u.confirm
    u.save!
    u
  end
end
