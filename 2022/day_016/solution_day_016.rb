INPUT = File.readlines("#{File.dirname(__FILE__)}/input_day_016.txt")
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

  memo[valve] = destination_names
  memo
end

SHOULD_OPEN = RATE_MAP.reduce([]) do |memo, (k, v)|
  if v != 0
    memo.push(k)
  end

  memo.sort { |a, b| RATE_MAP[b] <=> RATE_MAP[a] }
end

$debug = false

def cout(*val)
  if $debug
    puts *val
  end
end

def step_valve(step)
  step.last
end

def step_action(step)
  step.first
end

def new_step_as_open(valve)
  [:open, valve]
end

def new_step_as_move(valve)
  [:move, valve]
end

module Aoc22d16

  class Navigator

    INT_MAX = 4611686018427387903

    def initialize(graph)
      @graph = graph

      @distances = Hash.new { INT_MAX }
      @parents = Hash.new { nil }
      @denoted_and_unvisited = []
      @visited = Hash.new { false }
    end

    def get_next_unvisited
      @denoted_and_unvisited.shift
    end

    def has_been_visited?(v)
      @visited[v]
    end

    def denote_visited(v)
      @visited[v] = true
    end

    def re_sort_denoted
      @denoted_and_unvisited.sort! { |a, b| get_distance(a) <=> get_distance(b) }
    end

    def denote_distance(v, distance, parent)
      @distances[v] = distance
      @parents[v] = parent
      @denoted_and_unvisited.push(v)
    end

    def get_distance(point)
      @distances[point]
    end

    def get_reachable(v)
      @graph[v]
    end

    def get_trail_valves(last)
      v = last

      trail = [last]
      loop do
        parent = @parents[v]

        return nil if parent.nil?

        break if parent == @start

        trail.unshift(parent)
        v = parent
      end

      trail
    end

    def set_start(v)
      @start = v
      denote_distance(@start, 0, nil)
    end

  end

  class Chain
    # @return [Array<Symbol>]
    attr_reader :steps

    def initialize(steps = [], should_open)
      @steps = steps
      @_cache = {}
      @should_open = should_open
    end

    # @return [Integer]
    def pressure_after(limit)
      self.class.pressure_after_for_given_steps(limit, @steps)
    end

    # @return [Integer]
    def self.pressure_after_for_given_steps(limit, given_steps)
      i = 0
      unit = 0
      total = 0
      while i < limit
        total += unit
        step = given_steps[i]
        if !step.nil? && step_action(step) == :open
          unit += RATE_MAP[step_valve(step)]
        end
        i += 1
      end

      total
    end

    def new_with_steps(new_steps)
      existing_steps = @steps.dup
      self.class.new(existing_steps.concat(new_steps), @should_open)
    end

    def current_pressure
      pressure_after(@steps.count)
    end

    def done_opening?
      open_valves.count == @should_open.count
    end

    def already_opened?(valve)
      open_valves.include?(valve)
    end

    def remaining_valves(also_open_valves = [])
      (@should_open - open_valves - also_open_valves)
    end

    def open_valves
      cache_key = "open_valves_#{@steps.count}"
      @_cache[cache_key] ||= @steps.reduce([]) do |memo, step|
        if step_action(step) == :open
          memo.push(step_valve(step))
        end
        memo
      end
    end

    def greatest_possible_pressure_after(limit)
      cache_key = "max_possible_pressure_after_#{limit}_#{@steps.count}"
      if @_cache[cache_key].nil?
        remaining_valves_descending = remaining_valves.sort { |a, b| RATE_MAP[b] <=> RATE_MAP[a] }

        possible_steps = remaining_valves_descending.reduce([]) do |memo, remaining_valve|
          memo.concat([
            new_step_as_move(remaining_valve),
            new_step_as_open(remaining_valve),
          ])
        end

        @_cache[cache_key] = self.class.pressure_after_for_given_steps(limit, @steps + possible_steps)
      end
      @_cache[cache_key]
    end

  end

  class SingleExplorer
    attr_reader :chains

    def initialize
      # @type [Array<Chain>]
      @chains = []
    end

    # @return [Chain]
    def pop_candidate_chain(limit)
      # @type [Chain]
      chain_greatest_pressure = get_chain_greatest_pressure

      @chains = @chains.filter do |chain|
        first = chain.greatest_possible_pressure_after(limit)
        second = chain_greatest_pressure.greatest_possible_pressure_after(limit)
        first >= second
      end

      # The chain will the greatest possible pressure will be the last.
      @chains = @chains.sort do |a, b|
        first = a.greatest_possible_pressure_after(limit)
        second = b.greatest_possible_pressure_after(limit)
        first <=> second
      end

      @chains.pop
    end

    def get_chain_greatest_pressure
      @chains.max do |a, b|
        if a.is_a?(String) || b.is_a?(String)
          pp @chains
          abort
        end
        first = a.current_pressure
        second = b.current_pressure
        first <=> second
      end
    end

    def get_max_potential_chain(limit)
      @chains.max do |a, b|
        first = a.greatest_possible_pressure_after(limit)
        second = b.greatest_possible_pressure_after(limit)
        first <=> second
      end
    end

    def push_chain(chain)
      @chains.push(chain)
    end
  end

  # class DualExplorer
  #   def initialize(limit)
  #     # @type [Array<Array<Chain>>]
  #     @chain_pairs = []
  #     # @type [Integer]
  #     @limit = limit
  #   end
  #
  #   def push_pair(pair)
  #     @chain_pairs.push(pair)
  #   end
  #
  #   def pop_candidate_chain_pair
  #
  #     # @type [Chain]
  #     chain_pair_greatest_pressure = get_chain_pair_greatest_pressure
  #
  #     @chain_pairs.filter! do |chain_pair|
  #       # We have some set of remaining valves. Suppose they are opened in order.
  #       # We should take the sum of the two existing pressures, plus the maximum possible if there was just one chain moving forward.
  #       # chain.greatest_possible_pressure_after(@limit) >= chain_pair_greatest_pressure.greatest_possible_pressure_after(@limit)
  #     end
  #
  #     # The chain will the greatest possible pressure will be the last.
  #     # @chains.sort! { |a, b| a.greatest_possible_pressure_after(@limit) <=> b.greatest_possible_pressure_after(@limit) }
  #
  #     @chains.pop
  #
  #   end
  #
  #   def get_chain_pair_greatest_pressure
  #     @chain_paris.max do |a, b|
  #       (a.first.current_pressure + a.last.current_pressure) <=> (b.first.current_pressure + b.last.current_pressure)
  #     end
  #   end
  #
  # end
end

# Build a list of shortest path sequences, for every valve.
NAVS = GRAPH.keys.reduce({}) do |memo, start|
  nav = Aoc22d16::Navigator.new(GRAPH)
  nav.set_start(start)

  loop do
    valve = nav.get_next_unvisited

    break if valve.nil?

    re_sort = false
    nav.get_reachable(valve).each do |child|
      new_distance = nav.get_distance(valve) + 1
      if new_distance < nav.get_distance(child)
        nav.denote_distance(child, new_distance, valve)
        re_sort = true
      end
    end

    nav.re_sort_denoted if re_sort

    nav.denote_visited(valve)
  end

  memo[start] = nav

  memo
end

def get_max_pressure(explorer, limit)
  time_start = Time.now
  i = 0
  loop do

    # if i % 1000 == 0
    #   pp "Chain count @#{i}: #{explorer.chains.count}"
    # end

    max_chain = explorer.get_chain_greatest_pressure
    max_potential_chain = explorer.get_max_potential_chain(limit)
    # Have we reached the limit?
    step_count = max_chain.steps.count
    possible_pressure_max_chain = max_chain.greatest_possible_pressure_after(limit)
    possible_pressure_max_potential_chain = max_potential_chain.greatest_possible_pressure_after(limit)
    if step_count >= limit && possible_pressure_max_chain == possible_pressure_max_potential_chain
      break
    end

    candidate_chain = explorer.pop_candidate_chain(limit)
    if i == 0
      last_valve = :AA
    else
      last_valve = step_valve(candidate_chain.steps.last)
    end

    # Paths to all remaining valves
    remaining_valves = candidate_chain.remaining_valves

    if remaining_valves.count > 0
      remaining_valves.each do |remaining_valve|
        trail_valves = NAVS[last_valve].get_trail_valves(remaining_valve)
        path_move = trail_valves.map do |valve|
          new_step_as_move(valve)
        end
        child_chain_path = path_move.push(new_step_as_open(trail_valves.last))

        child_chain = candidate_chain.new_with_steps(child_chain_path)
        explorer.push_chain(child_chain)
      end
    else
      # Simply stay put.
      child_chain_path = [new_step_as_move(last_valve)]
      child_chain = candidate_chain.new_with_steps(child_chain_path)
      explorer.push_chain(child_chain)
    end

    i += 1
  end

  time_end = Time.now

  # pp time_end - time_start

  explorer.get_chain_greatest_pressure.pressure_after(limit)
end

# Approach using two single chains.
# 15 valves, so let's suppose a group of 7 and a group of 8.
# Take all combinations of 8, do analysis to get max.
# Take all differences of 7, do subsequent analysis.
# Find greatest sum.
half = SHOULD_OPEN.count / 2
should_open_sets = SHOULD_OPEN.combination(half).map(&:itself)
should_open_set_pairs = should_open_sets.map do |should_open_set|
  [
    should_open_set,
    SHOULD_OPEN - should_open_set
  ]
end

max_found = 0
should_open_set_pairs.each_with_index do |should_open_set_pair, i|
  if i % 100 == 0
    pp "Checking pair #{i}"
  end
  explorer_me = Aoc22d16::SingleExplorer.new
  explorer_me.push_chain(Aoc22d16::Chain.new([], should_open_set_pair.first))
  max_pressure_me = get_max_pressure(explorer_me, 26)

  explorer_elephant = Aoc22d16::SingleExplorer.new
  explorer_elephant.push_chain(Aoc22d16::Chain.new([], should_open_set_pair.last))
  max_pressure_elephant = get_max_pressure(explorer_elephant, 26)

  max_for_pair = max_pressure_me + max_pressure_elephant
  if max_for_pair > max_found
    pp "new max: #{max_for_pair}"
    max_found = max_for_pair
  end
end

pp max_found
