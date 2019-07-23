require_relative('./scripts/find_routes.rb')
require_relative('./scripts/timetable.rb')

FindRoute::route('Dworzec Zachodni', 'Rondo Rataje')
p Timetable::test()
