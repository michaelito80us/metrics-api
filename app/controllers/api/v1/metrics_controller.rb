class Api::V1::MetricsController < ApplicationController
  # POST /api/v1/metrics
  # Creates a new metric entry
  def create
    @metric = Metric.new(metric_params)
    if @metric.save
      render json: { message: 'Metric created successfully' }, status: :created
    else
      render json: { errors: @metric.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /api/v1/list
  # Retrieves the unique list of metric names
  def metric_list
    names = Metric.pluck(:name).uniq
    render json: { metric_list: names }
  end

  # POST /api/v1/averages
  # Retrieves metric entries within a specified time range, and averages them by minute, hour, and day
  def metric_averages
    metric_params = params.permit(:metric, :start_time, :end_time, :format, :timezone)
    user_timezone = metric_params[:timezone]
    start_time, end_time = parse_and_validate_times(metric_params[:start_time], metric_params[:end_time])

    # Check if start time and end time are valid
    if start_time.nil? || end_time.nil?
      render json: { error: 'end_time must be greater than start_time' }, status: :unprocessable_entity
      return
    end

    # Fetching the metric entries based on name and timestamp range
    metric_entries = Metric.where(name: metric_params[:metric].downcase,
                                  timestamp: start_time..end_time).order(timestamp: :asc)

    # Calculate the averages for all three intervals
    averages = calculate_averages(metric_entries, user_timezone)

    # Render the results in the JSON response
    render json: averages, status: :ok
  end

  private

  # Strong parameters for creating a metric
  def metric_params
    params.require(:metric).permit(:name, :value, :timestamp)
  end

  # Parses and validates start_time and end_time
  # Returns nil values if validation fails
  def parse_and_validate_times(start_time, end_time)
    start_time = DateTime.parse(start_time)
    end_time = DateTime.parse(end_time)
    return [nil, nil] if end_time <= start_time

    [start_time, end_time]
  end

  def calculate_averages(metric_entries, user_timezone)
    {
      per_minute: average_by_interval(metric_entries, :minute, user_timezone),
      per_hour: average_by_interval(metric_entries, :hour, user_timezone),
      per_day: average_by_interval(metric_entries, :day, user_timezone)
    }
  end

  def group_by_interval(metric_data, interval)
    metric_data.group_by do |entry|
      case interval
      when :minute then entry.timestamp.beginning_of_minute
      when :hour then entry.timestamp.beginning_of_hour
      when :day then entry.timestamp.beginning_of_day
      end
    end
  end

  def format_key(key, interval, user_timezone)
    case interval
    when :minute then key.in_time_zone(user_timezone).strftime('%Y-%m-%d %H:%M')
    when :hour then key.in_time_zone(user_timezone).strftime('%Y-%m-%d %H:00')
    when :day then key.in_time_zone(user_timezone).strftime('%Y-%m-%d')
    end
  end

  def calculate_average(entries)
    total_value = entries.sum(&:value)
    avg_value = total_value / entries.size.to_f
    format('%.1f', avg_value).to_f
  end

  # Averages the given metric data by the specified interval (:minute, :hour, or :day)
  # Returns a hash where keys are the beginning of the intervals and values are the calculated averages
  def average_by_interval(metric_data, interval, user_timezone)
    interval_data = group_by_interval(metric_data, interval)

    formatted_interval_data = interval_data.transform_keys do |key|
      format_key(key, interval, user_timezone)
    end

    formatted_interval_data.transform_values do |entries|
      calculate_average(entries)
    end
  end
end
