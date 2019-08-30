# frozen_string_literal: true

require_relative('./lib/find_routes.rb')
require_relative('./lib/timetable.rb')
require 'sinatra/base'
require 'json'

# Main Entrypoint
class Main < Sinatra::Base
  # Listen on all interfaces, this ensures
  # that app'll work inside docker container
  set :bind, '0.0.0.0'

  get '/api' do
    '<p>This is the poznan-mpk-api:</p>
      <a href="https://github.com/michalStarski/poznan-mpk-api">Github</a>'
  end

  get '/api/get_routes' do
    # Downcase to make parsing data easier
    from = params['from'].downcase
    to = params['to'].downcase
    response.headers['Content-Type'] = 'application/json'
    data = Timetable.routes(from, to).to_json
    if data['error']
      status 400
    else
      status 200
    end

    return data
  end

  get '/api/quick_look' do
    stop = params['stop'].downcase
    line = params['line'].downcase
    response.headers['Content-Type'] = 'application/json'

    data = Timetable.quick_look(line, stop)

    # Quick_look returns -1 when the stop is the last stop of the route
    # We have to filter it out
    data = data.delete_if { |entry| entry == -1 }

    return data.to_json
  end
end
