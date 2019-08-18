require_relative('./main.rb')
require 'sinatra'

configure do
  set :protection, :except => [:json_csrf]
end

run Sinatra::Application
