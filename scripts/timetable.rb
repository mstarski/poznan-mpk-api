require 'nokogiri'
require 'open-uri'
require 'pp'

module Timetable
    class << self

        def test
            link = get_departure_info_link('Dworzec Zachodni', 'Słowiańska', 19)
            get_nearest_arrival(link)
        end

        private 
            def get_departure_info_link(from, to, line)
                doc = Nokogiri::HTML(open("http://mpk.poznan.pl/component/transport/#{line}"))
                directions = ['left', 'right']

                directions.each {|direction|
                    route = doc.css("#box_timetable_#{direction} a")
                    route.each {|stop|
                        found = nil
                        stop_link = stop['href']
                        stop_name = stop.text
                        if stop_name == from && found.nil?
                            return stop_link
                        elsif stop_name == to 
                            found = stop_name
                        end
                    }
                }
            end

            def get_nearest_arrival(link, time=[Time.new.hour, Time.new.min])
                doc = Nokogiri::HTML(open("http://mpk.poznan.pl#{link}"))
            end
    end
end
