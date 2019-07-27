require_relative('./find_routes.rb')
require 'nokogiri'
require 'open-uri'
require 'pp'

module Timetable
    class << self

        def routes(from, to)
            routes = FindRoute::route(from, to)
            routes.each {|route|
                #Stop -> #Line -> #Stop ...
                i = 0
                from = nil
                to = nil
                line = nil
                transfer_checkpoint = nil
                route.each_slice(3) {|slice|
                    if i % 2 == 0
                        from = slice[0]
                        line = slice[1]
                        to = slice[2]
                        break if from.nil? || to.nil? || line.nil?
                        transfer_checkpoint = get_time(from, to, line, transfer_checkpoint)
                        from = to 
                    else
                        to = slice[1]
                        line = slice[0]
                        break if from.nil? || to.nil? || line.nil?
                        transfer_checkpoint = get_time(from, to, line, transfer_checkpoint)
                    end

                    puts transfer_checkpoint
                    i += 1
                }
            }
        end

        private 
            def get_time(from, to, line, relative_to)
                link = get_departure_info_link(from, to, line) 
                result = get_nearest_arrival(link, relative_to)

                result[:line] = line
                result[:dest] = to

                return result
            end

            def get_departure_info_link(from, to, line)
                doc = Nokogiri::HTML(open("http://mpk.poznan.pl/component/transport/#{line}"))
                doc.css(".FromTo").remove
                directions = ['left', 'right']

                directions.each {|direction|
                    found = nil
                    route = doc.css("#box_timetable_#{direction} a")
                    route.each {|stop|
                        if stop.text == from 
                            if found.nil?
                                return stop['href']
                            else
                                next
                            end
                        elsif stop.text == to
                            found = to
                        end
                    }
                }
            end

            def get_nearest_arrival(link, relative_to=nil, time=Time.new, weekday=Time.new.wday)
                doc = Nokogiri::HTML(open("http://mpk.poznan.pl#{link}"))

                stops_eta_timetable = doc.css('.timetable #MpkThisStop ~ .MpkStopsWrapper')
                stop_name = doc.css('#MpkThisStop').text

                #If we transfer, we have to adjust the next stop's arrival to be in time.
                unless relative_to.nil?
                    #Retrieve how much time it takes to go from start to stop
                    fixed_time = stops_eta_timetable.find {|stop|
                        #Get rid of \n and split string into [time_it_takes, stop_name]
                        eta, name = stop.text.delete!("\n").split("-")
                        #Find the stop that we are looking for 
                        name == relative_to['stop_name']
                    }
                    #Extract minutes
                    fixed_time = fixed_time.text.delete!("\n").split("-")[0].to_i
                    #Last stop of the route doesn't have minutes written next to it so we cover that case manually: stop before time + 2 min
                    if fixed_time == 0
                        fixed_time = stops_eta_timetable[stops_eta_timetable.length - 2].text.delete!("\n").split("-")[0].to_i
                    end
                    #Fix time object to have needed properties (set hours, minutes)
                    time = fix_time(relative_to[:hour], relative_to[:minutes], time, fixed_time)
                end
               
                #We only need hours and minutes here
                time = [time.hour, time.min]

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

                day_num_to_name = ["Sunday", "Monday", "Tuesday", "Thursday", "Wednesday", "Friday", "Saturday"]
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

                #Find the weekdays hour index - html_timetable[index +1/+3/+5] are the weekdays/saturdays/sundays minutes
                index = html_timetable.find_index {|cell| 
                    cell.text == time[0].to_s
                }

                initial_weekday = weekday
                alt_hours_counter = 3 #It is used to count what hour is being checked when the day changes
                hour_offset = 0
                minutes = nil

                #TODO think about refactor this block
                loop do
                    day_index = weekday % 6 == 0 ? weekday.to_s : "1"
                    day_data = week_metadata[day_index.to_sym]

                    #If there are no arivals the given day, check the next one
                    if index + day_data[:index_shift] >= html_timetable.length
                        weekday = (weekday + 1) % 7
                        index = 0                        
                        alt_hours_counter = (alt_hours_counter + 1) % 23
                        next
                    end

                    #Prevent from getting a departure that is in the past
                    minutes = get_minutes.call(html_timetable, index, day_data[:index_shift]).find {|m|
                        m.to_i > time[1].to_i
                    }

                    if minutes.nil?
                        index += 6
                        hour_offset += 1
                        minutes = get_minutes.call(html_timetable, index, day_data[:index_shift])[0]
                    end

                    break unless minutes.nil?
               end

                #If there are no departures at given day any more we look at the next one and then response changes a bit
                if initial_weekday != weekday
                    return {
                        :day => day_num_to_name[weekday.to_i],
                        :hour => alt_hours_counter,
                        :minutes => minutes,
                        :is_today => false,
                        :stop_name => stop_name,
                    }
                #Here's the response when everything went OK 
                else
                    return {
                        :day => day_num_to_name[weekday.to_i],
                        :hour => time[0] + hour_offset,
                        :minutes => minutes,
                        :is_today => true,
                        :stop_name => stop_name,
                    }
                end
            end

            #We do it like this to preserve time object properties (i.e it will change year, day etc when we add minutes)
            #offset is given in minutes
            def fix_time(hour, minutes, time, offset)
                loop do
                    time += 240
                    break if time.hour >= hour.to_i && time.min >= minutes.to_i
                end

                return time + (offset * 60)
            end
    end
end
