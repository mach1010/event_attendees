puts "Event Manager initialized"

lines = File.readlines("event_attendees.csv")
lines.each { |line| puts line }
