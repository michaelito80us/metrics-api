class Metric < ApplicationRecord
  validates :name, presence: true
  validates :value, presence: true, numericality: true
  validates :timestamp, presence: true

  before_save :downcase_name

  private

  def downcase_name
    self.name = name.downcase
  end
end
