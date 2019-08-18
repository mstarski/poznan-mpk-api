# frozen_string_literal: true

class Node
  def initialize(val)
    @value = val
    @edges = []
    @checked = false
    @parent = nil
  end
  attr_accessor :value, :edges, :checked, :parent

  def add_edge(node)
    return -1 if @edges.include? node

    @edges.push(node)
    node.edges.push(self)
  end
end
