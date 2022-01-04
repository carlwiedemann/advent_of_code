INPUT = File.readlines('./input-day-021.txt')

p1_position, p2_position = INPUT.map(&:strip).map do |line|
  line.split.last.to_i
end

class DieTwentyOne
  attr_reader :times_rolled

  MAX_VALUE = 100

  def initialize(start = 0)
    @start = start
    @times_rolled = 0
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
    if @start == 100
      @start = 1
    else
      @start += 1
    end
  end
end

class PlayerTwentyOne
  attr_reader :score

  MAX_POSITION = 10

  WINNING_SCORE = 1000

  def initialize(position)
    @position = position
    @score = 0
  end

  def move(distance)
    modulo = (@position + distance) % MAX_POSITION
    @position = modulo == 0 ? MAX_POSITION : modulo
  end

  def move_and_score(distance)
    move = move(distance)
    @score += move

    @score >= WINNING_SCORE
  end
end

p1 = PlayerTwentyOne.new(p1_position)
p2 = PlayerTwentyOne.new(p2_position)
die = DieTwentyOne.new

loop do
  break if p1.move_and_score(die.roll_thrice)
  break if p2.move_and_score(die.roll_thrice)
end

# Part 1
pp die.times_rolled * [p1.score, p2.score].min.to_i
