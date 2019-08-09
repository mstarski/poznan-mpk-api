require_relative('./scripts/find_routes.rb')
require_relative('./scripts/timetable.rb')
require 'sinatra'
require 'json'

get '/api' do
    '<p>This is the poznan-mpk-api:</p> 
    <a href="https://github.com/michalStarski/poznan-mpk-api">Github</a>'
end

get '/api/get_routes' do
    from = params['from']
    to = params['to']
    response.headers['Content-Type'] = 'application/json'
    data = Timetable::routes(from, to).to_json
    if data['error']
        status 400
    else
        status 200
    end

    return data
end

get '/api/quick_look' do
    stop = params['stop']
    line = params['line']
    response.headers['Content-Type'] = 'application/json'

    return Timetable::quick_look(line, stop)
end
