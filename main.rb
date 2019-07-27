require_relative('./scripts/find_routes.rb')
require_relative('./scripts/timetable.rb')

routes = FindRoute::route('Arciszewskiego', 'Szymanowskiego')

routes.each {|route|
    #Stop -> #Line -> #Stop ...
    i = 0
    from = nil
    to = nil
    line = nil
    route.each_slice(3) {|slice|
        if i % 2 == 0
            from = slice[0]
            line = slice[1]
            to = slice[2]
            break if from.nil? || to.nil? || line.nil?
            puts "#{from} => #{to} (#{line})", Timetable::get_time(from, to, line)

            from = to 
        else
            to = slice[1]
            line = slice[0]
            break if from.nil? || to.nil? || line.nil?
            puts "#{from} => #{to} (#{line})", Timetable::get_time(from, to, line)
        end
        i += 1
    }
    p "Dest: #{route[route.length - 1]}"
    p "============================="
}


