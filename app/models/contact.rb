class Contact < ApplicationRecord
  validates :phone, presence: true, uniqueness: true
end
