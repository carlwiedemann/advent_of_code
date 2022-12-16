module Aoc2022Day16
  class Navigator
    MINUTES = 30

    def initialize(graph)
      @graph = graph
      @total_flows = Hash.new { -1 }
      @parents = {}
      @denoted_and_unvisited = []
      @visited = Hash.new { false }
    end

    def set_starting_point(valve)
      @starting_point = valve
      denote_flow(@starting_point, 0, nil)
    end

    def denote_flow(valve, total_flow, parent_valve)
      @total_flows[valve] = total_flow
      @parents[valve] = parent_valve
      @denoted_and_unvisited.push(valve)
    end

    def get_total_flow(valve)
      @total_flows[valve]
    end

    def get_next_unvisited
      @denoted_and_unvisited.shift
    end

    def has_been_visited?(valve)
      @visited[valve]
    end

    def denote_visited(valve)
      @visited[valve] = true
    end

    def denote_unvisited(valve)
      @visited[valve] = false
    end

    def re_sort_denoted
      # @denoted_and_unvisited.sort! { |a, b| get_distance(a) <=> get_distance(b) }
    end

    def get_unvisited_destinations(valve)
      @graph[valve].filter do |potential_destination|
        !has_been_visited?(potential_destination.first)
      end
    end

    def get_entire_flow
      @total_flows.values.reduce(&:+)
    end

  end
end

INPUT = File.readlines('./input_day_016.txt')
lines = INPUT.map(&:strip)

RATE_MAP = lines.reduce({}) do |memo, line|
  parts = line.split(' ')

  valve = parts[1].to_sym
  rate = parts[4].gsub(/[^0-9]/, '').to_i

  memo[valve] = rate

  memo
end

base_graph = {
  START: [[:AA, 0]]
}

graph = lines.reduce(base_graph) do |memo, line|
  parts = line.split(' ')

  valve = parts[1].to_sym
  destination_names = parts[9..].map { _1.gsub(/[^a-z]/i, '').to_sym }

  open_valve = "#{valve.to_s}_OPEN".to_sym
  open_valve_destinations = [[valve, RATE_MAP[valve]]]

  valve_destinations = destination_names.reduce([]) do |memo2, destination|
    memo2.push([
      "#{destination.to_s}_OPEN".to_sym,
      0
    ])
    memo2.push([
      destination,
      0
    ])

    memo2
  end

  memo[valve] = valve_destinations
  memo[open_valve] = open_valve_destinations
  memo
end

nav = Aoc2022Day16::Navigator.new(graph)
nav.set_starting_point(:START)

$debug = true
def cout (*val)
  if $debug
    puts *val
  end
end

times = Aoc2022Day16::Navigator::MINUTES
times = 5
open_valves = []
last_value = nil
times.times do |i|

  valve = nav.get_next_unvisited

  break if valve.nil?

  # Get valid destinations.
  destinations = nav.get_unvisited_destinations(valve)

  re_sort = false
  destinations.each do |destination|
    destination_valve = destination.first
    destination_base_flow = destination.last

    total_flow = (Aoc2022Day16::Navigator::MINUTES - i) * destination_base_flow
    if nav.get_total_flow(destination_valve) < total_flow
      if /\S\S_OPEN/ =~ destination_valve.to_s
        open_valves.push(destination_valve)
      end
      nav.denote_flow(destination_valve, total_flow, valve)
      re_sort = true
    end
  end

  nav.re_sort_denoted if re_sort

  nav.denote_visited(valve)
end

pp nav.get_total_flow



