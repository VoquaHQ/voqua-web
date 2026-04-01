class Interview < ApplicationRecord
  belongs_to :question

  validates :first_answer, presence: true
end
