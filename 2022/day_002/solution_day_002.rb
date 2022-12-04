INPUT = File.readlines('./input_day_002.txt')
lines = INPUT.map(&:strip)

pairs = lines.map do |line|
  line.split(' ')
end

##
# Model game as enum:
#   0 := rock
#   1 := paper
#   2 := scissors
#
# Losing is a forward index, winning is a backward index, which can be handled through modular arithmetic.
#

def match_points(their_move, my_move)
  if their_move == my_move
    3
  elsif (my_move + 1) % 3 == their_move
    0
  else
    6
  end
end

# Part 1
sum = 0

pairs.each do |pair|
  their_move = 'ABC'.index(pair.first)
  my_move = 'XYZ'.index(pair.last)

  sum += match_points(their_move, my_move) + my_move + 1
end

pp sum

# Part 2
sum = 0

pairs.each do |pair|
  their_move = 'ABC'.index(pair.first)
  my_index = 'XYZ'.index(pair.last)
  my_move = (their_move - 1 + my_index) % 3

  sum += match_points(their_move, my_move) + my_move + 1
end

pp sum
