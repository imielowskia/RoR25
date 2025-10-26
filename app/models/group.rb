class Group < ApplicationRecord
  belongs_to :field
  has_many :students
end
