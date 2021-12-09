input = File.readlines('./input-day-01.txt')
depths = input.map(&:to_i)

def increases(depths)
  current_depth = depths[0]

  depths.reduce(0) do |memo, depth|
    if depth > current_depth
      memo += 1
    end
    current_depth = depth
    memo
  end
end

# Part 1
p increases(depths)

sums = depths.each_with_index.reduce([]) do |memo, (depth, i)|
  if depths[i + 1] && depths[i + 2]
    memo << depth + depths[i + 1] + depths[i + 2]
  end
  memo
end

# Part 2
p increases(sums)