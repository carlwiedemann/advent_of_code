INPUT = File.readlines("#{File.dirname(__FILE__)}/input_day_020.txt")
require_relative 'lib_day_020'
numbers = INPUT.map(&:strip).map(&:to_i)

# Part 1.
numbers1 = numbers.dup
nav = Aoc22d20nav.new(numbers1)

nav.size.times do |i|
  nav.move_item(i)
end

values = nav.get_values
zero_index = values.index(0)
sum = [1000, 2000, 3000].reduce(0) do |memo, i|
  memo + values[nav.constrain(zero_index + i)]
end

pp sum

# Part 2.
DECRYPTION_KEY = 811589153
numbers2 = numbers.dup.map do |number|
  number * DECRYPTION_KEY
end
nav = Aoc22d20nav.new(numbers2)

10.times do |j|
  pp j
  nav.size.times do |i|
    nav.move_item(i)
  end
end

values = nav.get_values
zero_index = values.index(0)
sum = [1000, 2000, 3000].reduce(0) do |memo, i|
  memo + values[nav.constrain(zero_index + i)]
end

pp sum
