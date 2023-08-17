class Api::V1::MetricsController < ApplicationController
  # POST /api/v1/metrics
  # Creates a new metric entry
  def create
    @metric = Metric.new(metric_params)
    if @metric.save
      entries = Metric.where(name: @metric.name).order(timestamp: :desc).limit(30)
      render json: { message: 'Metric created successfully', entries: }, status: :created
    else
      render json: { errors: @metric.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /api/v1/list
  # Retrieves the unique list of metric names
  def metric_list
    names = Metric.pluck(:name).uniq.sort
    metric_list = names.map do |name|
      { value: name, label: name.capitalize }
    end
    render json: { data: metric_list }, status: :ok
  end

  # POST /api/v1/averages
  # Retrieves metric entries within a specified time range, and averages them by minute, hour, and day
  def metric_averages
    metric_params = params.permit(:metric, :start_time, :end_time, :format, :timezone)
    Time.use_zone(metric_params[:timezone]) do
      start_time, end_time = parse_and_validate_times(metric_params[:start_time], metric_params[:end_time])

      # Check if start time and end time are valid
      if start_time.nil? || end_time.nil?
        render json: { error: 'end_time must be greater than start_time' }, status: :unprocessable_entity
        return
      end

      averages = Metric.calculate_averages(metric_params[:metric], start_time, end_time)

      render json: { name: metric_params[:metric].capitalize, averages: }, status: :ok
    end
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
