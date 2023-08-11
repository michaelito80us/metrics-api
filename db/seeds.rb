# Clear existing metric data
Metric.delete_all

# Set the start and end times
start_time = 3.days.ago
end_time = Time.now
counter = 0

# Generate measurements
current_time = start_time

while current_time <= end_time
  # Generate a random temperature value
  temperature = rand(10.0..35.0).round(1)

  # Create a metric entry
  Metric.create(name: 'TEMPERATURE', value: temperature, timestamp: current_time)
  counter += 1
  # Generate random time intervals for the next measurement
  current_time += case rand(1..100)
                  when 1..40  # 40% chance of adding measurements per second
                    10.second
                  when 41..70 # 30% chance of adding measurements per minute
                    10.minute
                  else # 30% chance of adding measurements per hour
                    1.hour
                  end
end

puts "Created #{counter} metric entries"
