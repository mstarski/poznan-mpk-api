require_relative('./scripts/find_routes.rb')
require_relative('./scripts/timetable.rb')
require 'sinatra'
require 'json'

get '/api' do
    '<p>This is the poznan-mpk-api:</p> 
    <a href="https://github.com/michalStarski/poznan-mpk-api">Github</a>'
end

post '/api/get_route' do
    from = params['from']
    to = params['to']
    response.headers['Content-Type'] = 'application/json'
    return Timetable::routes(from, to).to_json
end
