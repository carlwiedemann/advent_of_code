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
  class Chain

    # @return [Array<Step>]
    attr_reader :steps

    def initialize(steps)
      @steps = steps
    end

    def pressure_after(limit)
      i = 0
      unit = 0
      total = 0
      while i < limit
        total += unit
        step = steps[i]
        if !step.nil?
          if step.opens?
            unit += RATE_MAP[step.valve]
          end
        end
        i += 1
      end

      total
    end

  end

  class Step
    ACTION_MOVE_TO = :action_move_to
    ACTION_OPEN = :action_open

    attr_accessor :action
    attr_accessor :valve

    def initialize(action, valve)
      @action = action
      @valve = valve
    end

    def opens?
      @action == ACTION_OPEN
    end
  end
end

chain = Aoc22d16::Chain.new([
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :DD),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_OPEN, :DD),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :CC),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :BB),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_OPEN, :BB),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :AA),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :II),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :JJ),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_OPEN, :JJ),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :II),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :AA),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :DD),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :EE),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :FF),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :GG),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :HH),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_OPEN, :HH),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :GG),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :FF),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :EE),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_OPEN, :EE),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :DD),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_MOVE_TO, :CC),
  Aoc22d16::Step.new(Aoc22d16::Step::ACTION_OPEN, :CC),
])

pp chain.pressure_after(30)





