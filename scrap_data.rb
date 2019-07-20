#Utility to scrap tram data from mpk site and put it into JSON

require 'nokogiri'
require 'open-uri'
require 'json'
require 'pp'

ztm_data = {}

domain = "http://www.mpk.poznan.pl"
uri = "#{domain}/rozklad-jazdy"
doc = Nokogiri::HTML(open(uri))

puts "Starting scrapping process..."

line_links = doc.css '#box_lines .box_trams a'

line_links.each { |line_link|
	line_number = line_link['href'].split('/')[3]

	puts line_number

	line_page = Nokogiri::HTML(open("#{domain}/#{line_link['href']}"))

	directions = ['right', 'left']
	directions.each { |direction|

		route = line_page.css "#box_timetable_#{direction} a"
		route.each { |stop|
			stop_code = stop['href'].split('/')[4]
			stop_name = stop.text

			if ztm_data[stop_code].nil? then
				ztm_data[stop_code] = {
					:name => stop_name,
					:lines => [line_number]
				}
			else
				unless ztm_data[stop_code][:lines].include? line_number
					ztm_data[stop_code][:lines] << line_number
				end
			end
		}
	}
}

#Write data to the file
puts "Writing data to the file..."
File.open("ztm_data.json", 'w') { |f|
	f.write(ztm_data.to_json)
}

puts "Success."
