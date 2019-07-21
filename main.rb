require_relative('./graph')
require_relative('./node')
require_relative('./traverse')
require 'json'
require 'pp'

$ztm_data = JSON.load(File.new('./ztm_data.json'))
$stops_data = $ztm_data['stops_data']
$working_line_numbers = $ztm_data['working_line_numbers']

#Map names to code for user to be able to provide real stop names
$name_to_code = Hash.new
$stops_data.each {|code, data|
	if $name_to_code[data['name']].nil?
		$name_to_code[data['name']] = [code]
	else
		$name_to_code[data['name']] << code
	end
}

def ztm_find_route(start, stop)
	line_number_nodes = Hash.new
	#Map working line numbers to graph nodes
	$working_line_numbers.each {|number|
		line_number_nodes[number] = Node.new(number)
	}

	stop_nodes = Hash.new
	#Map stops to graph nodes
	$stops_data.each {|stop_code, data|
		stop_node = Node.new(stop_code)
		data['lines'].each {|line|
			stop_node.add_edge(line_number_nodes[line])
		}
		stop_nodes[stop_code] = stop_node
	}

	#Reverse nodes so the furthest one is not at the beginning
	line_number_nodes.each {|key, value|
		value.edges.reverse!
	}

	graph = Graph.new
	graph.root = stop_nodes[start]
	pp bfs(graph, stop)
end

def main(start, stop)
	$name_to_code[start].each {|start_code|
		$name_to_code[stop].each {|stop_code|
			ztm_find_route(start_code, stop_code)
		}
	}
end

#Wersje tego samego przystanku mają dodaną linię, która nie jedzie przez tą wersje (patrz. 12)
main('Dworzec Zachodni', 'Rondo Rataje')
