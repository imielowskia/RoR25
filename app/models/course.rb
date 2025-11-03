class Course < ApplicationRecord
  has_and_belongs_to_many :groups
  has_many :grades
  has_many :students, through: :grades
end
