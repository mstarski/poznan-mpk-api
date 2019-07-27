require 'nokogiri'
require 'open-uri'
require 'pp'

module Timetable
    class << self

        def get_time(from, to, line, relative_to)
            link = get_departure_info_link(from, to, line) 
            return get_nearest_arrival(link, relative_to)
        end

        private 
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
                unless relative_to.nil?
                    fixed_time = stops_eta_timetable.find {|stop|
                        eta, name = stop.text.delete!("\n").split("-")
                        name == relative_to['stop_name']
                    }

                    fixed_time = fixed_time.text.delete!("\n").split("-")[0].to_i

                    relative_hour_count = (time.hour - relative_to[:hour]).abs
                    relative_minutes_count = (time.min + relative_to[:minutes].to_i).abs
                    
                    time = time + (relative_hour_count * 60 * 60) + (relative_minutes_count * 60) + (fixed_time * 60)
                end

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

                    minutes = get_minutes.call(html_timetable, index, day_data[:index_shift]).find {|m|
                        m.to_i > time[1].to_i
                    }

                    break unless minutes.nil?

                    index += 6 
                    hour_offset += 1
                end

               
                if initial_weekday != weekday
                    return {
                        :day => day_num_to_name[weekday.to_i],
                        :hour => alt_hours_counter,
                        :minutes => minutes,
                        :is_today => false,
                        :stop_name => stop_name
                    }
                else
                    return {
                        :day => day_num_to_name[weekday.to_i],
                        :hour => time[0] + hour_offset,
                        :minutes => minutes,
                        :is_today => true,
                        :stop_name => stop_name
                    }
                end
            end
    end
end
