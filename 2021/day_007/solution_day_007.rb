INPUT = File.readlines('./input_day_007.txt')
positions = INPUT.first.to_s.split(',').map(&:strip).map(&:to_i)

position_data = positions.reduce({min: nil, max: nil, map: {}}) do |memo, p|
  memo[:map][p] = 0 unless memo[:map][p]
  memo[:map][p] += 1

  memo[:max] = p unless memo[:max] && memo[:max] > p
  memo[:min] = p unless memo[:min] && memo[:min] < p

  memo
end

min = Range.new(position_data[:min], position_data[:max]).reduce(nil) do |memo, i|
  possible = position_data[:map].reduce(0) do |memo2, (k, v)|
    memo2 += v * (k - i).abs
    memo2
  end

  memo = [i, possible] unless memo
  if possible < memo[1]
    memo = [i, possible]
  end

  memo
end

# Part 1
p min

min = Range.new(position_data[:min], position_data[:max]).reduce(nil) do |memo, i|
  possible = position_data[:map].reduce(0) do |memo2, (k, v)|
    diff = (k - i).abs
    series_sum = diff * (diff + 1) / 2
    memo2 += v * series_sum
    memo2
  end

  memo = [i, possible] unless memo
  if possible < memo[1]
    memo = [i, possible]
  end

  memo
end

# Part 2
p min
