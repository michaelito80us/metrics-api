class Metric < ApplicationRecord
  validates :name, presence: true
  validates :value, presence: true, numericality: true
  validates :timestamp, presence: true

  before_save :downcase_name

  scope :for_name_and_time_range, lambda { |name, start_time, end_time|
                                    where(name: name.downcase, timestamp: start_time..end_time).order(timestamp: :asc)
                                  }

  def self.calculate_averages(name, start_time, end_time, user_timezone)
    metric_entries = for_name_and_time_range(name, start_time, end_time)
    {
      per_minute: average_by_interval(metric_entries, :minute, user_timezone),
      per_hour: average_by_interval(metric_entries, :hour, user_timezone),
      per_day: average_by_interval(metric_entries, :day, user_timezone)
    }
  end

  # Averages the given metric data by the specified interval (:minute, :hour, or :day)
  # Returns a hash where keys are the beginning of the intervals and values are the calculated averages
  def self.average_by_interval(metric_data, interval, user_timezone)
    interval_data = group_by_interval(metric_data, interval)

    # Convert the keys to the user's time zone and format them
    formatted_interval_data = interval_data.transform_keys do |key|
      format_key(key, interval, user_timezone)
    end

    formatted_interval_data.transform_values do |entries|
      averages_calculation(entries)
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

  def self.format_key(key, interval, user_timezone)
    case interval
    when :minute then key.in_time_zone(user_timezone).strftime('%Y-%m-%d %H:%M')
    when :hour then key.in_time_zone(user_timezone).strftime('%Y-%m-%d %H:00')
    when :day then key.in_time_zone(user_timezone).strftime('%Y-%m-%d')
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
