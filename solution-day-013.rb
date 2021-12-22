INPUT = File.readlines('./input-day-013.txt')
all_lines = INPUT.map(&:strip)

raw_pairs = all_lines.filter do |line|
  !line.include?(' ') && line.length > 0
end

pairs_map = raw_pairs.reduce(Hash.new { false }) do |memo, raw_pair|
  memo[raw_pair] = true
  memo
end

raw_instructions = all_lines.filter do |line|
  line.include?(' ')
end

instructions = raw_instructions.map do |raw_instruction|
  axis, fold = raw_instruction.split.last.split('=')
  {
    axis: axis,
    value: fold.to_i,
  }
end

def count_of_points(paris_map)
  paris_map.filter { |_, v| v }.count
end

def display(pairs_map)
  coordinates = pairs_map.keys.map do |pair|
    pair.split(',').map(&:to_i)
  end
  max_x = coordinates.map { |c| c[0] }.max
  max_y = coordinates.map { |c| c[1] }.max

  output = ''

  (max_y + 1).times do |y|
    row = []
    (max_x + 1).times do |x|
      if coordinates.include?([x, y])
        row.push('#')
      else
        row.push('.')
      end
    end
    output += row.join(' ') + "\n"
  end

  output
end

def fold(pairs_map, instruction)
  # Determine the axis, which will move the pairs.
  if instruction[:axis] == 'y'
    pair_index = 1
  else
    pair_index = 0
  end

  # We fold upward around the given value.
  revised_map = pairs_map.keys.reduce({}) do |memo, raw_pair|
    pair = raw_pair.split(',').map(&:to_i)
    # If the y value of the pair is less than the value of the instruction, we skip.
    if instruction[:value] < pair[pair_index]
      # In this case, we have to figure out the new pair
      pair[pair_index] = 2 * instruction[:value] - pair[pair_index]
      memo[raw_pair] = false
      memo[pair.join(',')] = true
    else
      memo[raw_pair] = true
    end

    memo
  end

  revised_map.filter { |_, v| v }
end

# Part 1
p count_of_points(fold(pairs_map, instructions.first))

final_map = instructions.reduce(pairs_map) do |memo, instruction|
  fold(memo, instruction)
end

# Part 2
puts display(final_map)