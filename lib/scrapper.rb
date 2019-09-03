# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'json'
require 'pp'

# Utility to scrap tram data from mpk site and put it into JSON
class Scrapper
  # dest: string, path to a dir where the file will be saved (relative to root of a project)
  # data will be saved under dest/ztm_data.json
  # log_info: bool, decides if method should log informations about the scrapping process
  def self.scrap_data(dest, log_info)
    ztm_data = {
      stops_data: {},
      working_line_numbers: []
    }

    domain = 'http://www.mpk.poznan.pl'
    uri = "#{domain}/rozklad-jazdy"
    doc = Nokogiri::HTML(open(uri))

    puts 'Starting scrapping process...' if log_info

    line_links = doc.css '#box_lines .box_trams a'
    line_links.each do |line_link|
      line_number = line_link['href'].split('/')[3]
      puts line_number if log_info
      line_page = Nokogiri::HTML(open("#{domain}/#{line_link['href']}"))

      directions = %w[right left]
      directions.each do |direction|
        route = line_page.css "#box_timetable_#{direction} a"
        route.each do |stop|
          stop_code = stop['href'].split('/')[4]
          stop_name = stop.text&.downcase

          if ztm_data[:stops_data][stop_code].nil?
            ztm_data[:stops_data][stop_code] = {
              name: stop_name,
              lines: [line_number]
            }
          else
            unless ztm_data[:stops_data][stop_code][:lines].include? line_number
              ztm_data[:stops_data][stop_code][:lines] << line_number
            end
          end
        end
      end
      ztm_data[:working_line_numbers] << line_number
    end
    # Write data to the file

    out_dir = "#{__dir__}/../#{dest}"
    Dir.mkdir(out_dir) unless File.directory?(out_dir)

    puts 'Writing data to the file...' if log_info
    File.open("#{out_dir}/ztm_data.json", 'w+') do |f|
      f.write(ztm_data.to_json)
    end

    puts "Success, data saved to #{dest}/ztm_data.json" if log_info
  end
end
