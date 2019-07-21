def bfs(graph, target)
	queue = []
	graph.root.checked = true
	queue << graph.root
	while !queue.empty? do
		node = queue.shift
		if node.value == target
			return get_route(node)
		end
		node.edges.each { |n|
			unless n.checked
				n.checked = true
				n.parent = node
				queue << n
			end
		}
	end
end

def get_route(destination)
	route = []
	route << destination.value
	while destination.parent
		route << destination.parent.value
		destination = destination.parent
	end
	return route.reverse
end
