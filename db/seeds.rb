# db/seeds.rb

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
  Metric.create(name: 'temperature', value: temperature, timestamp: current_time)
  counter += 1
  # Generate random time intervals for the next measurement
  current_time += case rand(1..100)
                  when 1..60  # 60% chance of adding measurements per minute
                    1.minute
                  when 61..90 # 30% chance of adding measurements per hour
                    1.hour
                  else        # 10% chance of adding measurements per day
                    1.day
                  end
end

puts "Created #{counter} metric entries"
