require_relative('./find_routes.rb')
require_relative('../utils/time-tools.rb')
require 'nokogiri'
require 'open-uri'
require 'pp'

module Timetable
    class << self
        def routes(from, to)
            result = Array.new
            routes = FindRoute::route(from, to)
            if routes == -1
                return { :error => true, :message => 'Incorrect stop name' }
            end
            
            routes.each {|route|
                p route
                tmp = Array.new #Array to hold all transfer information
                #Stop -> #Line -> #Stop ...
                last_stop_index = 0
                transfer_checkpoint = nil
                ((route.length - 1) / 2).times {
                    from, line, to = route.slice(last_stop_index, 3)
                    transfer_checkpoint = get_time(from, to, line, transfer_checkpoint)
                    last_stop_index += 2
                    #Error only occures when tram takes two different routes in two 
                    #different directions
                    unless transfer_checkpoint[:error]
                        tmp << transfer_checkpoint
                    end
                }
                unless tmp.empty?
                    result << tmp
                end
            }
            return result.sort! { |a, b| a.length <=> b.length }
        end

        def quick_look(line, stop)
            result = []
            links = get_departure_info_link(stop, nil, line)
            links.each {|link|
                result << get_nearest_arrival(link, nil, nil)
            }
            return result
        end

        private 
            def get_time(from, to, line, relative_to)
                link = get_departure_info_link(from, to, line) 
                result = get_nearest_arrival(link, to, relative_to)
                result[:line] = line

                return result
            end

            def get_departure_info_link(from, to, line)
                doc = Nokogiri::HTML(open("http://mpk.poznan.pl/component/transport/#{line}"))
                doc.css(".FromTo").remove
                directions = ['left', 'right']
                both_dirs_links = Array.new #Used for quick_look

                directions.each {|direction|
                    from_meta = Hash.new 
                    to_meta = Hash.new 
                    route = doc.css("#box_timetable_#{direction} a")
                    route.each_with_index {|stop, index|
                        if stop.text == from 
                            from_meta['index'] = index
                            from_meta['href'] = stop['href']
                            both_dirs_links << stop['href']
                        elsif stop.text == to
                            to_meta['index'] = index
                            to_meta['href'] = stop['href']
                        end

                        #We have to make sure both stops are on the route (There are trams that dont go the same way both directions)
                        if !from_meta['index'].nil? && !to_meta['index'].nil?\
                           && from_meta['index'] < to_meta['index'] && !to.nil?
                                return from_meta['href']
                        end
                    }
                }
                return to.nil? ? both_dirs_links : -1
            end

            def get_nearest_arrival(link, dest, relative_to=nil, time=[Time.new.hour, Time.new.min], 
                                    weekday=Time.new.wday, existing_doc=nil)

                #Link will only be broken when the different-route-tram is being considered
                if link == -1
                    return { :error => true, message: 'Route not found' } 
                end

                doc = existing_doc || Nokogiri::HTML(open("http://mpk.poznan.pl#{link}"))
            
                stops_eta_timetable = doc.css('.timetable #MpkThisStop ~ .MpkStopsWrapper')
                unless dest.nil?
                    journey_time = get_journey_time(stops_eta_timetable, dest).to_i
                end
                stop_name = doc.css('#MpkThisStop').text

                #If we transfer, we have to adjust the next stop's arrival to be in time.
                unless relative_to.nil?
                    #Here we adjust time to be after arrival from the previous stop
                    fixed_time = TimeTools::add_minutes([relative_to[:hour].to_i, 
                        relative_to[:minutes].to_i], relative_to[:journey_time])
                    return get_nearest_arrival(link, dest, nil, fixed_time, relative_to[:day], doc)
                end


                #Remove unnecessary nodes from the dom
                doc.css('.timetable td.Left').remove

                html_timetable = doc.css('.MpkTimetableRow > td')
                #---html_timetable array format---
                #Weekdays hour 
                #Weekdays minutes 

                #Saturdays hour
                #Saturdays minutes

                #Sundays hour
                #Sundays hours

                day_num_to_name = ["Sunday", "Monday", "Tuesday", "Thursday", 
                                "Wednesday", "Friday", "Saturday"]
                week_metadata = {
                    "0": {
                        name: 'Sundays',
                        index_shift: 5,
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

                #We are getting departure minutes from given hour and day here
                get_minutes = Proc.new { |html_timetable, index, shift|
                    html_timetable[index + shift].text.split(" ")
                }

                #Find the weekdays hour index - html_timetable[index +1/+3/+5] are 
                #the weekdays/saturdays/sundays minutes

                index = html_timetable.find_index {|cell| 
                    cell.text == time[0].to_s
                }

                initial_weekday = weekday
                alt_hours_counter = 4 #It is used to count what hour is being checked when the day changes
                hour_offset = 0
                minutes = nil

                loop do
                    day_index = weekday % 6 == 0 ? weekday.to_s : "1"
                    day_data = week_metadata[day_index.to_sym]

                    #If there are no arivals the given day, check the next one
                    if index + day_data[:index_shift] > html_timetable.length
                        weekday = (weekday + 1) % 7
                        index = 0                        
                        alt_hours_counter = (alt_hours_counter + 1) % 23
                        next
                    end

                    #Prevent from getting a departure that is in the past
                    minutes = get_minutes.call(html_timetable, index, day_data[:index_shift])
                    unless hour_offset != 0
                        minutes = minutes.find {|m|
                            m.to_i > time[1].to_i
                        }
                    else
                        #if we've jumped to the next hour, we can take the first element without
                        #calculating anything since we know it's gonna be the earliest one
                        minutes = minutes[0]
                    end

                    #Index + 6 jumps to the next hour in the table
                    if minutes.nil?
                        index += 6
                        hour_offset += 1
                    end

                    break unless minutes.nil?
                end

                #If there are no departures at given day any more we look 
                #at the next one and then response changes a bit
                if initial_weekday != weekday
                    return {
                        :day => weekday,
                        #Loop ends before adding +1 to the counter so we have to add it here
                        :hour => alt_hours_counter + 1, 
                        :minutes => minutes,
                        :is_today => false,
                        :stop_name => stop_name,
                        :journey_time => journey_time,
                        :dest => dest
                    }
                #Here's the response when everything went OK 
                else
                    return {
                        :day => weekday,
                        :hour => time[0] + hour_offset,
                        :minutes => minutes,
                        :is_today => true,
                        :stop_name => stop_name,
                        :journey_time => journey_time,
                        :dest => dest
                    }
                end
            end

            def get_journey_time(timetable, stop_name)
                journey_data = timetable.find {|stop| 
                    stop_data = stop.text.delete("\n").split("-")                    
                    #There are stops with one "-" in its name code below handles that case
                    if stop_data.length == 3
                        stop_data = [stop_data[0], "#{stop_data[1]}-#{stop_data[2]}"]
                    end
                    stop_data.include? stop_name 
                }
                journey_data = journey_data.text.delete!("\n").split("-")
                
                if journey_data.length == 1
                    return timetable[timetable.length - 2].text.delete("\n").split("-")[0].to_i + 2 
                else
                    return journey_data[0].to_i
                end
           end
     end
end
