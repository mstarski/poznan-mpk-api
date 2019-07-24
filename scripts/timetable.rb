require 'nokogiri'
require 'open-uri'
require 'pp'

module Timetable
    class << self

        def get_time(route)

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

            def get_nearest_arrival(link, time=[Time.new.hour, Time.new.min], weekday=Time.new.wday)
                doc = Nokogiri::HTML(open("http://mpk.poznan.pl#{link}"))
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

                #Find the weekdays hour index - html_timetable[index +1/+3/+5] are the weekdays/saturdays/sundays minutes
                index = html_timetable.find_index {|cell| 
                    cell.text == time[0].to_s
                }

                minutes = []
                hour_offset = 0
                while minutes.length == 0 do
                    #If it's sunday
                    if weekday == 0
                        minutes = html_timetable[index + 5].text.split(" ")
                    #Else if it's saturday
                    elsif weekday == 6
                        minutes = html_timetable[index + 3].text.split(" ")
                    else
                        minutes = html_timetable[index + 1].text.split(" ")
                    end
                    index += 6 
                    hour_offset += 1
                end

                hour_offset -= 1
                unless hour_offset == 0 
                    nearest_arrival = "#{time[0] + hour_offset}:#{minutes[0]}"
                end

                return nearest_arrival
            end
    end
end
