class Group < ApplicationRecord
  belongs_to :field
  has_many :students
  has_and_belongs_to_many :courses
end
