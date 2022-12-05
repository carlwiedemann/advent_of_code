INPUT = File.readlines('./input_day_005.txt')
lines = INPUT.map(&:strip)

# What data do we have?
v_stack_lines = lines.filter do |line|
  /^\[/ =~ line
end

v_stacks = v_stack_lines.map do |line|
  line.chars.each_slice(4).map(&:join).map { _1.gsub(/[^A-Z]/,'') }
end

stacks = v_stacks.transpose.map { |v_stack| v_stack.reverse.reject { |char| char == '' } }

# Two separate stores since everything in Ruby is a reference.
(store1, store2) = stacks.each_with_index.reduce([{}, {}]) do |memo, (stack, i)|
  memo[0][i] = stack.dup
  memo[1][i] = stack.dup
  memo
end

# What steps do we take?
verbose_steps = lines.filter do |line|
  /^move/ =~ line
end

steps = verbose_steps.map do |step|
  step.gsub('move ', '')
    .gsub(' from ', ',')
    .gsub(' to ', ',').split(',').map(&:to_i)
end

# Part 1
store1 = steps.reduce(store1) do |memo, (amount, from, to)|
  memo[to - 1].concat(memo[from - 1].slice!(-amount..).reverse)

  memo
end

list = store1.values.reduce('') do |memo, stack|
  memo + stack.last
end

pp list

# Part 2
store2 = steps.reduce(store2) do |memo, (amount, from, to)|
  memo[to - 1].concat(memo[from - 1].slice!(-amount..))

  memo
end

list = store2.values.reduce('') do |memo, stack|
  memo + stack.last
end

pp list
