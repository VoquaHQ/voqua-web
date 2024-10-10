class Question < ApplicationRecord
  belongs_to :ballot

  validates :ballot, presence: true
  validates :title, presence: true
end
