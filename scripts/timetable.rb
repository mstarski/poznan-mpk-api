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
                doc.css(".FromTo").remove
                directions = ['left', 'right']

                directions.each {|direction|
                    route = doc.css("#box_timetable_#{direction} a")
                    #TODO DOKONCZYC TO JAK NIE BEDE MIAL LAGA MÓZGU
                }
            end

            def get_nearest_arrival(link, time=[Time.new.hour, Time.new.min], weekday=Time.new.wday)
              p link
            end
    end
end
