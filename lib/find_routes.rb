# frozen_string_literal: true

require_relative('../data-structures/graph')
require_relative('../data-structures/node')
require_relative('../utils/traverse')
require_relative('../utils/ztm_data_model')
require 'pp'

# Module containing methods for finding routes between two given stops
module FindRoute

  class << self
    # Returns an array containing avaliable routes in a format:
    # [ stop1, line_number1, stop1, ... ]
    # Which means at the stop1 get into line1 go to the stop2 etc.
    def route(start, stop)
      name_to_code = parse_stop_names
      # Handle case when user types incorrect stop name
      return -1 if name_to_code[start].nil? || name_to_code[stop].nil?

      routes = []
      name_to_code[start].each do |start_code|
        name_to_code[stop].each do |stop_code|
          current_route = []
          find_routes(start_code, stop_code).each_with_index do |element, index|
            current_route << parse_route_element(element, index)
          end
          routes << current_route unless routes.include? current_route
        end
      end
      routes
    end

    private

    # Private method that uses BFS algorithm to find routes between two stops
    def find_routes(start, stop)
      stop_nodes = create_graph
      graph = Graph.new
      graph.root = stop_nodes[start]
      bfs(graph, stop)
    end

    # Create graph from the ztm_data
    def create_graph
      line_nodes = {}
      # Map working line numbers to graph nodes
      ZtmModel::WORKING_LINE_NUMBERS.each { |num| line_nodes[num] = Node.new(num) }
      stop_nodes = {}

      # Map stops to graph nodes
      ZtmModel::STOPS_DATA.each do |stop_code, data|
        stop_node = Node.new(stop_code)

        data['lines'].each { |line| stop_node.add_edge(line_nodes[line]) }
        stop_nodes[stop_code] = stop_node
      end

      # Reverse nodes so the furthest one is not at the beginning
      line_nodes.each { |_, value| value.edges.reverse! }
      stop_nodes
    end

    # Map stop names to code for user to be able to provide real stop names
    def parse_stop_names
      result = {}
      ZtmModel::STOPS_DATA.each do |code, data|
        if result[data['name']].nil?
          result[data['name']] = [code]
        else
          result[data['name']] << code
        end
      end
      result
    end

    def parse_route_element(element, index)
      if index.even?
        ZtmModel::STOPS_DATA[element]['name']
      else
        element
      end
    end
  end
end
