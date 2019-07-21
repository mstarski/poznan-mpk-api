class Node
	def initialize(val)
		@value = val
		@edges = Array.new
		@checked = false
		@parent = nil
	end
	attr_accessor :value, :edges, :checked, :parent

	def add_edge(node)
		if @edges.include? node
			return -1
		end
		@edges.push(node)
		node.edges.push(self)
	end

end
