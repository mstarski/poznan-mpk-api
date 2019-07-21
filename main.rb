require_relative('./graph')
require_relative('./node')
require_relative('./traverse')
require 'json'
require 'pp'

def ztm_tram_routes(start, stop)
	ztm_data = JSON.load(File.new('./ztm_data.json'))
	stops_data = ztm_data['stops_data']
	working_line_numbers = ztm_data['working_line_numbers']

	line_number_nodes = {}
	#Map working line numbers to graph nodes
	working_line_numbers.each {|number|
		line_number_nodes[number] = Node.new(number)
	}

	stop_nodes = {}
	#Map stops to graph nodes
	stops_data.each {|stop_code, data|
		stop_node = Node.new(stop_code)
		data['lines'].each {|line|
			stop_node.add_edge(line_number_nodes[line])
		}
		stop_nodes[data['name']] = stop_node
	}

	graph = Graph.new
	graph.root = stop_nodes[start]
	if graph.root.nil?
		p 'Start does not exist.'
	end
	route = bfs(graph, stop_nodes[stop].value)
	pp route
end

#Example usage
ztm_tram_routes('Szymanowskiego', 'Rondo Rataje')
