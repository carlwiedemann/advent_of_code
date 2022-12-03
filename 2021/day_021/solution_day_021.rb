INPUT = File.readlines('./input_day_021.txt')

p1_position, p2_position = INPUT.map(&:strip).map do |line|
  line.split.last.to_i
end

class DieTwentyOne
  attr_reader :times_rolled
  attr_reader :universes

  MAX_VALUE = 100

  def initialize(start = 0)
    @start = start
    @times_rolled = 0
    @universes = 1
  end

  def roll_thrice
    @times_rolled += 3

    rolls = [
      next_value,
      next_value,
      next_value,
    ]

    rolls.sum
  end

  def next_value
    @universes *= 3
    if @start == 100
      @start = 1
    else
      @start += 1
    end
  end
end

class QuantumDieTwentyOne

  ##
  # Keys are scores of 3 rolls, and values are times at which the rolls occur.
  #
  # These are all the possible rolls and scores for a given turn. There are 27 different outcomes, i.e. 27 different
  # universes for every turn.
  #
  def self.distances_and_frequencies
    if @_distances_and_frequencies.nil?
      @_distances_and_frequencies = Hash.new { 0 }
      3.times do |i|
        3.times do |j|
          3.times do |k|
            @_distances_and_frequencies[i + j + k + 3] += 1
          end
        end
      end
    end

    @_distances_and_frequencies
  end

end

class PlayerTwentyOne
  attr_reader :score
  attr_reader :position

  MAX_POSITION = 10

  def initialize(position, winning_score)
    @position = position
    @score = 0
    @winning_score = winning_score
  end

  def self.get_next_position(position, distance)
    modulo = (position + distance) % MAX_POSITION
    modulo == 0 ? MAX_POSITION : modulo
  end

  def move_and_score(distance)
    next_position = PlayerTwentyOne.get_next_position(@position, distance)
    @position = next_position
    @score += next_position

    @score >= @winning_score
  end
end

p1 = PlayerTwentyOne.new(p1_position, 1000)
p2 = PlayerTwentyOne.new(p2_position, 1000)
die = DieTwentyOne.new

loop do
  break if p1.move_and_score(die.roll_thrice)
  break if p2.move_and_score(die.roll_thrice)
end

# Part 1
pp die.times_rolled * [p1.score, p2.score].min.to_i

# Part 2
# Each starting point will create several branching conditions.
#
# Every turn will generate 27 different universes, but several are duplicates, there are only 7 unique universes.
#
# Each of these 7 provides some score and potential way toward the score of 21.
#
# All score trees are identical and they create different mirrored position states as they descend. The position states
# then determine the score, and the score determines who wins or not.
#
# Both players will share a tree, since the universes are not exclusive to one player.
#
# This should be a dynamic programming problem. We should be able to populate unique node values that can later be
# summed up.
#
# Each node in the graph will have the following inputs:
#
# current_positions: [Integer p1, Integer p2]
# current_scores: [Integer s1, Integer s2]
# root_multiplier: Integer rm
#
# Using these values, we can calculate:
#
# winning_counts: [Integer wc1, Integer wc2]
#
# The node will either be a final winner for one of the players or not. If it is a final winner, then its winning_counts
# will be [rm * 1, 0] or [0, rm * 1], since the node itself has a multiplier value.
#
# If it is not a final winner, then its winning counts will be the array-sum of each child (there are 7) times the
# root multiplier, e.g.
#
# winning_counts = [0, 0]
# children.each do |child|
#   winning_counts[0] += child[0]
#   winning_counts[1] += child[1]
# end

# Let's populate clear winners.
#
base_score_oracle = {}

MIN_SCORE = 0
MIN_WINNING_SCORE = 21
MAX_NON_WINNING_SCORE = MIN_WINNING_SCORE - 1

MAX_POINTS_PER_TURN = 10
# The very top score for the game will be the last non-winning score, plus the maximum points,
MAX_POSSIBLE_SCORE = MAX_NON_WINNING_SCORE + MAX_POINTS_PER_TURN

START_POSITION = 1
END_POSITION = 10

# We have a lot of different parameters to use in the cache for the scores.
def inputs_as_key((s1, s2), (p1, p2), next_turn)
  "k__#{s1}_#{s2}__#{p1}_#{p2}__#{next_turn}".to_sym
end

# We need to be mindful of turns.
TURN_INDICES = [0, 1]

# For any score `21 <= s <= 30`, it will be a winner, regardless of position.
MIN_WINNING_SCORE.upto(MAX_POSSIBLE_SCORE) do |winner_score|
  MIN_SCORE.upto(MAX_NON_WINNING_SCORE) do |loser_score|
    # Positions are irrelevant for these.
    START_POSITION.upto(END_POSITION) do |winner_position|
      START_POSITION.upto(END_POSITION) do |loser_position|
        TURN_INDICES.each do |current_turn|
          # These will be winner-take-all, regardless of the next turn.
          key = inputs_as_key([winner_score, loser_score], [winner_position, loser_position], current_turn)
          base_score_oracle[key] = [1, 0]
          inverse_key = inputs_as_key([loser_score, winner_score], [loser_position, winner_position], current_turn)
          base_score_oracle[inverse_key] = [0, 1]
        end
      end
    end
  end
end

# Now we need to deal with scores that are `0 <= s < 21`. These will have some set of winners and some set of losers.
MAX_NON_WINNING_SCORE.downto(MIN_SCORE) do |score_i|
  MAX_NON_WINNING_SCORE.downto(MIN_SCORE) do |score_j|
    # We will have different outcomes for each position.
    START_POSITION.upto(END_POSITION) do |position_i|
      START_POSITION.upto(END_POSITION) do |position_j|
        TURN_INDICES.each do |current_turn|

          # Suppose each score oracle position set is [next_to_move, not_next_to_move]
          current_positions = [position_i, position_j]
          current_scores = [score_i, score_j]

          # One of my favorite techniques for flipping between zero and one.
          next_turn = 1 - current_turn

          children = []

          # This will give us the next positions, for every distance and frequency.
          QuantumDieTwentyOne.distances_and_frequencies.each do |(distance, frequency)|
            next_position_for_player = PlayerTwentyOne.get_next_position(current_positions[current_turn], distance)
            next_positions = current_positions.clone
            next_scores = current_scores.clone
            next_positions[current_turn] = next_position_for_player
            next_scores[current_turn] += next_position_for_player

            children.push(base_score_oracle[inputs_as_key(next_scores, next_positions, next_turn)].map { _1 * frequency })
          end

          winning_counts = [0, 0]
          children.each do |child|
            winning_counts[0] += child[0]
            winning_counts[1] += child[1]
          end
          base_score_oracle[inputs_as_key(current_scores, current_positions, current_turn)] = winning_counts

        end
      end
    end
  end
end

# Part 2.
pp base_score_oracle[inputs_as_key([0, 0], [p1_position, p2_position], 0)]
