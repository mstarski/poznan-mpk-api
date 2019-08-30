# frozen_string_literal: true

require_relative('../data-structures/graph')
require_relative('../data-structures/node')
require_relative('../utils/traverse')
require_relative('../utils/ztm_data_model')
require 'pp'

# Finds routes between two given stops
module FindRoute
  # Map names to code for user to be able to provide real stop names
  name_to_code = {}
  ZtmModel::STOPS_DATA.each do |code, data|
    if name_to_code[data['name']].nil?
      name_to_code[data['name']] = [code]
    else
      name_to_code[data['name']] << code
    end
  end

  class << self
    # Returns an array containing avaliable routes in a format:
    # [ stop1, line_number1, stop1, ... ]
    # Which means at the stop1 get into line1 go to the stop2 etc.
    def route(start, stop)
      # Handle case when user types incorrect stop name
      return -1 if name_to_code[start].nil? || name_to_code[stop].nil?

      routes = []
      current_route = []
      name_to_code[start].each do |start_code|
        name_to_code[stop].each do |stop_code|
          current_route = []
          ztm_find_routes(start_code, stop_code).each_with_index do |element, index|
            current_route << if index.even?
                               ZtmModel::STOPS_DATA[element]['name']
                             else
                               element
                             end
          end
          routes << current_route unless routes.include? current_route
        end
      end
      routes
    end

    private

    # Private method that uses BFS algorithm to find routes between two stops
    def ztm_find_routes(start, stop)
      line_number_nodes = {}
      # Map working line numbers to graph nodes
      ZtmModel::WORKING_LINE_NUMBERS.each do |number|
        line_number_nodes[number] = Node.new(number)
      end

      stop_nodes = {}
      # Map stops to graph nodes
      ZtmModel::STOPS_DATA.each do |stop_code, data|
        stop_node = Node.new(stop_code)

        data['lines'].each do |line|
          stop_node.add_edge(line_number_nodes[line])
        end
        stop_nodes[stop_code] = stop_node
      end

      # Reverse nodes so the furthest one is not at the beginning
      line_number_nodes.each do |_key, value|
        value.edges.reverse!
      end

      graph = Graph.new
      graph.root = stop_nodes[start]
      bfs(graph, stop)
    end
  end
end
