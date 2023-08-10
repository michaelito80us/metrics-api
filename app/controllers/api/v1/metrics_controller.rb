class Api::V1::MetricsController < ApplicationController
  def create
    @metric = Metric.new(metric_params)

    if @metric.save
      render json: { message: 'Metric created successfully' }, status: :created
    else
      render json: { errors: @metric.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def metric_list
    names = Metric.pluck(:name).uniq
    render json: { metric_list: names }
  end

  def metric_entries
    metric_name = params[:name]
    metric_entries = Metric.where(name: metric_name).order(timestamp: :asc)

    puts "metric_name: #{metric_name}"
    puts average_per_minute(metric_entries)
    puts "--------"
    puts average_per_hour(metric_entries)
    puts "--------"
    puts average_per_day(metric_entries)
    puts "--------"

    render json: metric_entries
  end

  private

  def metric_params
    params.require(:metric).permit(:name, :value, :timestamp)
  end

  def average_per_minute(metric_data)
    interval_data = metric_data.group_by { |entry| entry.timestamp.beginning_of_minute }

    interval_data.transform_values do |entries|
      total_value = entries.sum(&:value)
      avg_value = total_value / entries.size.to_f
      format('%.1f', avg_value).to_f
    end
  end

  def average_per_hour(metric_data)
    interval_data = metric_data.group_by { |entry| entry.timestamp.beginning_of_hour }

    interval_data.transform_values do |entries|
      total_value = entries.sum(&:value)
      avg_value = total_value / entries.size.to_f
      format('%.1f', avg_value).to_f
    end
  end

  def average_per_day(metric_data)
    interval_data = metric_data.group_by { |entry| entry.timestamp.beginning_of_day }

    interval_data.transform_values do |entries|
      total_value = entries.sum(&:value)
      avg_value = total_value / entries.size.to_f
      format('%.1f', avg_value).to_f
    end
  end
end
