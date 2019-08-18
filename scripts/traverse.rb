# frozen_string_literal: true

def bfs(graph, target)
  queue = []
  graph.root.checked = true
  queue << graph.root
  until queue.empty?
    node = queue.shift
    return get_route(node) if node.value == target

    node.edges.each do |n|
      next if n.checked

      n.checked = true
      n.parent = node
      queue << n
    end
  end
end

def get_route(destination)
  route = []
  route << destination.value
  while destination.parent
    route << destination.parent.value
    destination = destination.parent
  end
  route.reverse
end
