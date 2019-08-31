# frozen_string_literal: true

require_relative('./find_routes.rb')
require_relative('../utils/time-tools.rb')
require 'nokogiri'
require 'open-uri'
require 'pp'

# Module containing methods for finding departure and arrival
# informations based on given route and time
module Timetable
  class << self
    # Returns detailed time-based information about routes
    def routes(from, to)
      result = []
      routes = FindRoute.route(from, to)
      return { error: true, message: 'Incorrect stop name' } if routes == -1

      routes.each do |route|
        tmp = [] # Array to hold all transfer information
        # Stop -> #Line -> #Stop ...
        last_stop_index = 0
        ((route.length - 1) / 2).times do
          from, line, to = route.slice(last_stop_index, 3)
          transfer_checkpoint = get_time(from, to, line, transfer_checkpoint || nil)
          last_stop_index += 2
          # Error only occures when tram takes two different routes in two
          # different directions
          tmp << transfer_checkpoint unless transfer_checkpoint[:error]
        end
        result << tmp unless tmp.empty?
      end
      result.sort! { |a, b| a.length <=> b.length }
    end

    def quick_look(line, stop)
      results = []
      links = get_departure_info_link(stop, nil, line)
      links.each do |link|
        result = get_nearest_arrival(link, nil, nil)
        unless result.nil? || result == -1
          result[:line] = line
          results << result
        end
      end
      results
    end

     private

    def get_time(from, to, line, relative_to)
      link = get_departure_info_link(from, to, line)
      result = get_nearest_arrival(link, to, relative_to)
      result[:line] = line

      result
    end

    def get_departure_info_link(from, to, line)
      doc = Nokogiri::HTML(open("http://mpk.poznan.pl/component/transport/#{line}"))

      doc.css('.FromTo').remove
      directions = %w[left right]
      both_dirs_links = [] # Used for quick_look

      directions.each do |direction|
        from_meta = {}
        to_meta = {}
        route = doc.css("#box_timetable_#{direction} a")
        route.each_with_index do |stop, index|
          # Downcase because to enable all-lowercase inputs
          if stop.text&.downcase == from&.downcase
            from_meta['index'] = index
            from_meta['href'] = stop['href']
            both_dirs_links << stop['href']
          elsif stop.text&.downcase == to&.downcase
            to_meta['index'] = index
            to_meta['href'] = stop['href']
          end

          # We have to make sure both stops are on the route
          # (There are trams that dont go the same way both directions)
          if !from_meta['index'].nil? && !to_meta['index'].nil?\
             && from_meta['index'] < to_meta['index'] && !to.nil?
            return from_meta['href']
          end
        end
      end
      to.nil? ? both_dirs_links : -1
    end

    def get_nearest_arrival(link, dest, relative_to = nil, time = [Time.new.hour, Time.new.min],
                            weekday = Time.new.wday, existing_doc = nil)

      # Link will only be broken when the different-route-tram is being considered
      return { error: true, message: 'Route not found' } if link == -1

      doc = existing_doc || Nokogiri::HTML(open("http://mpk.poznan.pl#{link}"))

      stops_eta_timetable = doc.css('.timetable #MpkThisStop ~ .MpkStopsWrapper')

      unless dest.nil?
        journey_time = get_journey_time(stops_eta_timetable, dest).to_i
      end

      stop_name = doc.css('#MpkThisStop').text

      # If we transfer, we have to adjust the next stop's arrival to be in time.
      unless relative_to.nil?
        # Here we adjust time to be after arrival from the previous stop
        fixed_time = TimeTools.add_minutes([relative_to[:hour].to_i,
                                            relative_to[:minutes].to_i], relative_to[:journey_time])
        return get_nearest_arrival(link, dest, nil, fixed_time, relative_to[:day], doc)
      end

      full_route = doc.css('.MpkNextStop')
      final_destination = full_route[full_route.length - 1].text

      # Remove unnecessary nodes from the dom
      doc.css('.timetable td.Left').remove

      html_timetable = doc.css('.MpkTimetableRow > td')
      #---html_timetable array format---
      # Weekdays hour
      # Weekdays minutes

      # Saturdays hour
      # Saturdays minutes

      # Sundays hour
      # Sundays hours

      week_metadata = {
        "0": {
          name: 'Sundays',
          index_shift: 5
        },
        "6": {
          name: 'Saturdays',
          index_shift: 3
        },
        "1": {
          name: 'Weekdays',
          index_shift: 1
        }
      }

      # We are getting departure minutes from given hour and day here
      get_minutes = proc { |timetable, index, shift| timetable[index + shift].text.split(' ') }

      # Find the weekdays hour index - html_timetable[index +1/+3/+5] are
      # the weekdays/saturdays/sundays minutes

      index = html_timetable.find_index { |cell| cell.text == time[0].to_s }

      return -1 if index.nil?

      initial_weekday = weekday
      alt_hours_counter = 4 # It is used to count what hour is being checked when the day changes
      hour_offset = 0
      minutes = nil

      loop do
        day_index = (weekday % 6).zero? ? weekday.to_s : '1'
        day_data = week_metadata[day_index.to_sym]

        # If there are no arivals the given day, check the next one
        if index + day_data[:index_shift] > html_timetable.length
          weekday = (weekday + 1) % 7
          index = 0
          alt_hours_counter = (alt_hours_counter + 1) % 23
          next
        end

        # Prevent from getting a departure that is in the past
        minutes = get_minutes.call(html_timetable, index, day_data[:index_shift])

        # If we've jumped to the next hour, we can take the first element without
        # calculating anything since we know it's gonna be the earliest one
        minutes = hour_offset != 0 ? minutes[0] : minutes.find { |m| m.to_i > time[1].to_i }

        # Index + 6 jumps to the next hour in the table
        if minutes.nil?
          index += 6
          hour_offset += 1
        end
        break unless minutes.nil?
      end

      # Response base
      response = {
        day: weekday,
        minutes: minutes,
        stop_name: stop_name,
        final_destination: final_destination
      }

      # If there are no departures at given day any more we look
      # at the next one and then response changes a bit
      if initial_weekday != weekday
        # Loop ends before adding +1 to the counter so we have to add it here
        response[:hour] = alt_hours_counter + 1
        response[:is_today] = false

      # Here's the response when everything went OK
      else
        response[:hour] = time[0] + hour_offset
        response[:is_today] = true
      end

      response[:journey_time] = journey_time
      response[:dest] = dest

      # Filter out nil fields since we dont need them
      response.delete_if { |_, value| value.nil? }
      response
    end

    def get_journey_time(timetable, stop_name)
      journey_data = timetable.find do |stop|
        stop_data = stop.text.delete("\n").split('-')
        # There are stops with one "-" in its name code below handles that case
        if stop_data.length == 3
          stop_data = [stop_data[0], "#{stop_data[1]}-#{stop_data[2]}"]
        end
        stop_data.collect! { |x| x&.downcase }
        stop_data.include? stop_name.downcase
      end
      journey_data = journey_data.text.delete!("\n").split('-')

      if journey_data.length == 1
        return timetable[timetable.length - 2].text.delete("\n").split('-')[0].to_i + 2
      end

      journey_data[0].to_i
    end
   end
end
