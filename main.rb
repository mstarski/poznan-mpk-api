require_relative('./graph')
require_relative('./node')
require_relative('./traverse')
require 'json'
require 'pp'

ztm_data = JSON.load(File.new('./ztm_data.json'))
line_nodes = []
graph = Graph.new
