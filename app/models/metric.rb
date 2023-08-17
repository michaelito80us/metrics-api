class Metric < ApplicationRecord
  validates :name, presence: true
  validates :value, presence: true, numericality: true
  validates :timestamp, presence: true

  before_save :downcase_name

  scope :for_name_and_time_range, lambda { |name, start_time, end_time|
                                    where(name: name.downcase, timestamp: start_time..end_time).order(timestamp: :asc)
                                  }

  def self.calculate_averages(name, start_time, end_time)
    metric_entries_day = for_name_and_time_range(name, start_time.beginning_of_day, end_time.end_of_day)
    metric_entries_hour = for_name_and_time_range(name, start_time.beginning_of_hour, end_time.end_of_hour)
    metric_entries_minute = for_name_and_time_range(name, start_time.beginning_of_minute, end_time.end_of_minute)

    {
      per_minute: average_by_interval(metric_entries_minute, :minute),
      per_hour: average_by_interval(metric_entries_hour, :hour),
      per_day: average_by_interval(metric_entries_day, :day)
    }
  end

  # Averages the given metric data by the specified interval (:minute, :hour, or :day)
  # Returns a hash where keys are the beginning of the intervals and values are the calculated averages
  def self.average_by_interval(metric_data, interval)
    interval_data = group_by_interval(metric_data, interval)

    # Convert the keys to the user's time zone and format them
    interval_data.map do |key, entries|
      {
        interval: key,
        average: averages_calculation(entries)
      }
    end
  end

  def self.group_by_interval(metric_data, interval)
    metric_data.group_by do |entry|
      case interval
      when :minute then entry.timestamp.beginning_of_minute
      when :hour then entry.timestamp.beginning_of_hour
      when :day then entry.timestamp.beginning_of_day
      end
    end
  end

  def self.averages_calculation(entries)
    total_value = entries.sum(&:value)
    avg_value = total_value / entries.size.to_f
    format('%.1f', avg_value).to_f
  end

  private

  def downcase_name
    self.name = name.downcase
  end
end
