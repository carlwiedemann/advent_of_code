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

def cout (*val)
  if $debug
    puts *val
  end
end

def step_valve(step)
  !@_step_value_cache.nil? || (@_step_value_cache = {})
  @_step_value_cache[step] ||= step.to_s.split('_').last.to_sym
end

def step_action(step)
  !@_step_action_cache.nil? || (@_step_action_cache = {})
  @_step_action_cache[step] ||= step.to_s.split('_').first.to_sym
end

def new_step_as_open(valve)
  !@_new_as_open_cache.nil? || (@_new_as_open_cache = {})
  @_new_as_open_cache[valve] ||= "open_#{valve}".to_sym
end

def new_step_as_move(valve)
  !@_new_as_move_cache.nil? || (@_new_as_move_cache = {})
  @_new_as_move_cache[valve] ||= "move_#{valve}".to_sym
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

    def get_trail(last)
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

    def initialize(steps = [])
      @steps = steps
      @_cache = {}
    end

    # @return [Array]
    def last_step
      @steps.last
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
        # if !step.nil? && step.opens?
        #   unit += RATE_MAP[step.valve]
        # end
        if !step.nil? && step_action(step) == :open
          unit += RATE_MAP[step_valve(step)]
        end
        i += 1
      end

      total
    end

    def new_with_step(new_step)
      existing_steps = @steps.dup
      self.class.new(existing_steps.push(new_step))
    end

    def new_with_steps(new_steps)
      existing_steps = @steps.dup
      self.class.new(existing_steps.concat(new_steps))
    end

    def current_pressure
      pressure_after(@steps.count)
    end

    def done_opening?
      open_valves.count == SHOULD_OPEN.count
    end

    def already_opened?(valve)
      open_valves.include?(valve)
    end

    def remaining_valves
      (SHOULD_OPEN - open_valves)
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

    def max_possible_pressure_after(limit)
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

  class Explorer
    attr_reader :chains

    # @param [Array<Chain>] chains
    def initialize(chains, limit)
      # @type [Array<Chain>]
      @chains = chains
      # @type [Integer]
      @limit = limit
    end

    # @return [Chain]
    def extract_candidate_chain

      # @type [Chain]
      max_chain = get_max_chain

      @chains.filter! do |chain|
        chain.max_possible_pressure_after(@limit) >= max_chain.max_possible_pressure_after(@limit)
      end

      @chains.sort! { |a, b| a.max_possible_pressure_after(@limit) <=> b.max_possible_pressure_after(@limit) }

      @chains.pop
    end

    def get_max_chain
      @chains.max { |a, b| a.current_pressure <=> b.current_pressure }
    end

    def get_max_potential_chain
      @chains.max { |a, b| a.max_possible_pressure_after(@limit) <=> b.max_possible_pressure_after(@limit) }
    end

    # # @return [Integer]
    # def get_max_chain_pressure
    #   get_max_chain.pressure_after(@limit)
    # end

    def push_chain(chain)
      @chains.push(chain)
    end

  end
end

# chain0 = Aoc22d16::Chain.new([
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE, :DD),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_OPEN, :DD),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE, :CC),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE, :BB),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_OPEN, :BB),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :AA),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :II),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :JJ),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_OPEN, :JJ),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :II),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :AA),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :DD),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :EE),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :FF),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :GG),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :HH),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_OPEN, :HH),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :GG),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :FF),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :EE),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_OPEN, :EE),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :DD),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :CC),
#   # Aoc22d16::Step.new(Aoc22d16::Step::ACTION_OPEN, :CC),
# ])

# pp chain0.pressure_after(30)
# pp chain0.max_possible_pressure_after(30)
# pp '--'
# pp chain1.pressure_after(30)
# pp chain1.max_possible_pressure_after(30)
# pp '--'

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

def get_path(from, to)
  NAVS[from].get_trail(to)
end

# Part 1
LIMIT = 30
explorer = Aoc22d16::Explorer.new([
  Aoc22d16::Chain.new([])
], LIMIT)

i = 0
loop do

  max_chain = explorer.get_max_chain
  max_potential_chain = explorer.get_max_potential_chain
  if max_chain.steps.count >= LIMIT && max_chain == max_potential_chain
    break
  end

  candidate_chain = explorer.extract_candidate_chain
  if i == 0
    last_valve = :AA
  else
    last_valve = step_valve(candidate_chain.steps.last)
  end

  # Paths to all remaining valves
  remaining_valves = candidate_chain.remaining_valves

  if remaining_valves.count > 0
    remaining_valves.each do |remaining_valve|
      path = get_path(last_valve, remaining_valve)
      path_to_remaining_valve = path.map do |valve|
        new_step_as_move(valve)
      end
      path_final = path_to_remaining_valve.push(new_step_as_open(path.last))

      child_chain = candidate_chain.new_with_steps(path_final)
      explorer.push_chain(child_chain)
    end
  else
    child_chain = candidate_chain.new_with_steps([new_step_as_move(last_valve)])
    explorer.push_chain(child_chain)
  end

  i += 1
end

pp explorer.get_max_chain.pressure_after(30)




