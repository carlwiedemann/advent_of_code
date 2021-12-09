input = File.readlines('./input-day-02.txt')

initial = { x: 0, y: 0 }

final = input.reduce(initial) do |memo, step|
  command, i_string = step.split(' ')
  i = i_string.to_i

  sign = command == 'up' ? -1 : 1

  field = command == 'forward' ? :x : :y

  memo[field] += i * sign

  memo
end

# Part 1
p final[:x] * final[:y]

initial = { x: 0, y: 0, a: 0 }

final = input.reduce(initial) do |memo, step|
  command, i_string = step.split(' ')
  i = i_string.to_i

  if command == 'forward'
    memo[:x] += i
    memo[:y] += memo[:a] * i
  else
    sign = command == 'up' ? -1 : 1
    memo[:a] += i * sign
  end

  memo
end

# Part 2
p final[:x] * final[:y]