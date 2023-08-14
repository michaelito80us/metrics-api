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
    render json: { metric_list: names }, status: :ok
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

    averages = Metric.calculate_averages(metric_params[:metric], start_time, end_time, user_timezone)

    render json: averages, status: :ok
  end

  # POST /api/v1/detailed_list
  # Retrevies all the last 30 entries of a metric
  def detailed_list
    metric_params = params.permit(:metric, :format)
    metric = metric_params[:metric]

    # Check if metric exists
    if Metric.where(name: metric).empty?
      render json: { error: 'metric does not exist' }, status: :unprocessable_entity
      return
    end

    # Retrieve last 30 entries of metric
    entries = Metric.where(name: metric).order(timestamp: :desc).limit(30).reverse

    render json: entries, status: :ok
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
end
