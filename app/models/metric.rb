class Metric < ApplicationRecord
  validates :name, presence: true
  validates :value, presence: true, numericality: true
  validates :timestamp, presence: true
end
