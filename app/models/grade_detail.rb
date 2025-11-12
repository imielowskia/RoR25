class GradeDetail < ApplicationRecord
  belongs_to :course
  belongs_to :student

  validates :grade, presence: true,
            numericality: { greater_than_or_equal_to: 2, less_than_or_equal_to: 5, message: 'musi być liczbą pomiędzy 2 a 5' }
end
