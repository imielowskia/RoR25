class Grade < ApplicationRecord
  belongs_to :student
  belongs_to :course
  validates :grade, presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 2, less_than_or_equal_to: 5, message: 'musi być liczbą całkowitą między 2 a 5' }
end
