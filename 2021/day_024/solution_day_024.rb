require 'json'
INPUT = File.readlines('./input_day_024.txt')

instruction_sets = INPUT.reduce([]) do |memo, line|
  line_parts = line.to_s.strip.split

  action, var_name, operand = line_parts

  if action == 'inp'
    instruction_set = []
    memo.push(instruction_set)
    instruction = [
      action.to_sym,
      var_name.to_sym,
      :INPUT
    ]
  else
    instruction_set = memo.last
    instruction = [
      action.to_sym,
      var_name.to_sym,
      /[wxyz]/ === operand ? operand.to_sym : operand.to_i,
    ]
  end

  instruction_set.push(instruction)

  memo
end

class Math24

  attr_reader :values

  def initialize
    @values = {
      w: 0,
      x: 0,
      y: 0,
      z: 0,
    }
  end

  def value_of(maybe_var)
    maybe_var.is_a?(Symbol) ? @values[maybe_var] : maybe_var
  end

  def inp(a, b)
    @values[a] = b
  end

  def mul(a, b)
    @values[a] *= value_of(b)
  end

  def add(a, b)
    @values[a] += value_of(b)
  end

  def div(a, b)
    @values[a] /= value_of(b)
  end

  def mod(a, b)
    @values[a] %= value_of(b)
  end

  def eql(a, b)
    @values[a] = @values[a] == value_of(b) ? 1 : 0
  end

  def perform_instructions(instruction_set, input_value)
    instruction_set.each do |instruction|
      operand = instruction[2] == :INPUT ? input_value : instruction[2]
      self.send(instruction[0], instruction[1], operand)
    end
  end
end

stack = []
instruction_sets.each_with_index do |instruction_set, i|
  n5 = instruction_set[5][2]
  n15 = instruction_set[15][2]
  if n5 > 0
    stack.push([i, n15])
  else
    instruction = stack.pop
    pp "must have input[#{i}] == input[#{instruction[0]}] + #{instruction[1] + n5}"
  end
end

# Unique Steps
# Fifth [4]
# Sixth [5]
# Sixteenth [15]
#
# [0]     inp w
# [1]     mul x 0       # Set x to zero
# [2]     add x z       # Set x to z
# [3]     mod x 26      # x is the modulo of z % 26 (range 0->25)
# [4]*    div z 1       # Keep z as-is (sometimes we divide by 26)
# [5]*    add x 15      # add 15 to (z % 26), but could be another number.
# [6]     eql x w       # Is `N5 + (z % 26)` equal to w? Depends on the what was added [5], might be 0 might be 1
# [7]     eql x 0       # Flip x (`N5 + (z % 26) != w`)
# [8]     mul y 0       # Set y to zero
# [9]     add y 25      # Set y to 25
# [10]    mul y x       # y is either 25 or 0
# [11]    add y 1       # y is either 26 or 1
# [12]    mul z y       # multiply z by 26 or 1 (might reverse step [4], depends on [5])
# [13]    mul y 0       # set y to zero
# [14]    add y w       # set y to w
# [15]*   add y 15      # add 15 to y, but could be another number
# [16]    mul y x       # y either stays the same or is zero (depends on 5)
# [17]    add z y       # z increases by y
#
#
# x = ((z % 26) + N5 != w) ? 1 : 0   # N5 must be less than zero to get x == 0
# z = (z / N4)                       # N4 is 26 if N5 is less than zero
# if x
#   z = 26 * z + w + N15
# end
#
largest = 49917929934999
smallest = 11911316711816