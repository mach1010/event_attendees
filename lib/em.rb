require "csv"
require "sunlight/congress"
require 'erb'
require 'date'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_form_letters(id, form_letter)
  Dir.mkdir('output') unless Dir.exists? 'output'
  filename = "output/thanks_#{id}.html"
  File.open(filename, 'w') { |file| file.puts form_letter }
end

def clean_phone_number(homephone)
  digits = homephone.split('').select { |x| x =~ /\d/ }.join
  digits.slice!(0) if digits.start_with? '1'
  digits.length == 10 ? "(#{digits[0..2]})#{digits[3..5]}-#{digits[6..9]}" : nil
end

def parse_date(date)
  DateTime.strptime(date, '%m/%d/%y %H:%M')
end

def sort_most_frequent (values)
  Hash[values.sort_by(&:last).reverse]
end

puts "EventManager initialized."

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
hours_registered = Hash.new(0)
days_registered = Hash.new(0)
template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone = clean_phone_number(row[:homephone])
  regdate = parse_date(row[:regdate])
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  
  form_letter = erb_template.result(binding)
  save_form_letters(id, form_letter)
  hours_registered[regdate.hour] += 1
  days_registered[regdate.wday] += 1
end
sort_most_frequent(hours_registered).each {|k, v| puts "#{v} person(s) registered at #{k} hundred hours"}
sort_most_frequent(days_registered).each {|k, v| puts "#{v} person(s) registered on #{Date::DAYNAMES[k]}"}
puts 'done and done.'