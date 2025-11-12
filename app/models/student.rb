class Student < ApplicationRecord
  belongs_to :group
  has_many :grades
  has_many :courses, through: :grades
  has_many :grade_details
  validates :album, presence: true, format: { with: /\A\d{5}\z/, message: 'musi zawierać dokładnie 5 cyfr' }
  before_validation :normalize_imie

  private
  def normalize_imie
    return if imie.blank?
    self.imie = imie.to_s.strip.capitalize.to_s
  end

end
