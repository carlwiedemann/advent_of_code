INPUT = File.readlines("#{File.dirname(__FILE__)}/input_day_020.txt")
require_relative 'lib_day_020'
numbers = INPUT.map(&:strip).map(&:to_i)

originals = numbers.each_with_index.map do |number, i|
  [i, number]
end

nav = D20nav.new(originals)

originals.each do |original|
  nav.move_item(original)
end

values = nav.get_values
zero_index = values.index(0)
sum = [1000, 2000, 3000].reduce(0) do |memo, i|
  memo + values[nav.constrain(zero_index + i)]
end

pp sum








