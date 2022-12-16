INPUT = File.readlines('./input_day_016.txt')
lines = INPUT.map(&:strip)

RATE_MAP = lines.reduce({}) do |memo, line|
  parts = line.split(' ')

  valve = parts[1].to_sym
  rate = parts[4].gsub(/[^0-9]/, '').to_i

  memo[valve] = rate

  memo
end

GRAPH = lines.reduce({}) do |memo, line|
  parts = line.split(' ')

  valve = parts[1].to_sym
  destination_names = parts[9..].map { _1.gsub(/[^a-z]/i, '').to_sym }

  # open_valve = "#{valve.to_s}_OPEN".to_sym
  # open_valve_destinations = [[valve, RATE_MAP[valve]]]

  # valve_destinations = destination_names.reduce([]) do |memo2, destination|
  #   memo2.push([
  #     "#{destination.to_s}_OPEN".to_sym,
  #     0
  #   ])
  #   memo2.push([
  #     destination,
  #     0
  #   ])
  #   memo2
  # end
  valve_destinations = destination_names

  memo[valve] = valve_destinations
  # memo[open_valve] = open_valve_destinations
  memo
end
pp RATE_MAP
pp GRAPH

$debug = true

def cout (*val)
  if $debug
    puts *val
  end
end

module Aoc22d16
  class Node
    attr_reader :valve
    attr_reader :opened

    attr_accessor :children

    def initialize(parent, valve, opened = false)
      @parent = parent
      @opened = opened
      @valve = valve
      @children = []
    end

    # @return [Aoc22d16::Node]
    def self.append(parent, value, opened)
      child = Node.new(parent, value, opened)
      if parent.nil?
        return child
      end

      parent.children.push(child)

      parent
    end
  end

end

IS_OPEN = 1
IS_CLOSED = 0

minutes = 5
open_valves = []
last_value = nil
tree = Aoc22d16::Node.append(nil, :AA, IS_CLOSED)
pp '--'

cursor = :AA
TOTAL = 30

# max_flow = 0
# def explore(cursor, flows, depth, _i = 0)
#   # pp "#{('> ' * _i)}#{cursor}"
#   if depth > 0
#     child_valves = GRAPH[cursor]
#     child_valves.each do |child_valve|
#       remain = depth - 1
#       explore(child_valve, flows, remain, _i + 1)
#       explore(child_valve, flows + [RATE_MAP[child_valve] * remain], remain, _i + 1)
#     end
#   else
#     pp flows
#   end
# end

explore(:AA, [], 2)


# Dijkstra from every point to get shortest paths
# NxN on flow rates
# Go through grid in-order, turning valves
# measure each and take max
