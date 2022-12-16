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
pp GRAPH

$debug = true
def cout (*val)
  if $debug
    puts *val
  end
end

minutes = Aoc2022Day16::Navigator::MINUTES
minutes = 5
open_valves = []
last_value = nil
minutes.times do |i|

end

pp nav.get_total_flow



