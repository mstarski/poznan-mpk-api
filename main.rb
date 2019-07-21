require_relative('./graph')
require_relative('./node')
require_relative('./traverse')
require 'json'
require 'pp'

ztm_data = JSON.load(File.new('./ztm_data.json'))
stops_data = ztm_data[:stops_data]
working_line_numbers = ztm_data[:working_line_numbers]

pp working_line_numbers
