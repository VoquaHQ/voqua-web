class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable
         #, :omniauthable

  has_many :user_profiles, dependent: :destroy
  has_many :profiles, through: :user_profiles
  has_many :ballots, through: :profiles
  belongs_to :main_profile, class_name: 'Profile', dependent: :destroy

  validates :main_profile, presence: true
  validates_associated :main_profile

  accepts_nested_attributes_for :main_profile
end
