class Student < ApplicationRecord
  belongs_to :group
  has_many :grades
  has_many :courses, through: :grades
end
