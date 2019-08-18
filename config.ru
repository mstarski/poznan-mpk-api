require_relative('./main.rb')
require 'sinatra'

STDOUT.sync = true

configure do
  set :protection, except: [:json_csrf]
end

run Sinatra::Application
