INPUT = File.readlines('./input-day-005.txt')
lines = INPUT.map(&:strip)

coordinate_sets = lines.map do |line|
  line.split('->').map do |pair|
    pair.split(',').map(&:to_i)
  end
end

def set_is_h(set)
  set[0][1] == set[1][1]
end

def set_is_v(set)
  set[0][0] == set[1][0]
end

def get_coordinate_keys(set)
  if set_is_v(set)
    x = set[0][0]
    keys = (Range.new(*[set[0][1], set[1][1]].sort)).map do |y|
      "#{x},#{y}"
    end
  elsif set_is_h(set)
    y = set[0][1]
    keys = (Range.new(*[set[0][0], set[1][0]].sort)).map do |x|
      "#{x},#{y}"
    end
  else
    xi = set[0][0]
    xf = set[1][0]

    yi = set[0][1]
    yf = set[1][1]

    xd = xf - xi
    yd = yf - yi

    x_opt = xd > 1 ? 1 : -1
    y_opt = yd > 1 ? 1 : -1

    keys = (xd.abs + 1).times.map do |i|
      x = xi + i * x_opt
      y = yi + i * y_opt
      "#{x},#{y}"
    end
  end

  keys
end

h_and_v_coordinate_sets = coordinate_sets.select do |coordinate_set|
  set_is_h(coordinate_set) || set_is_v(coordinate_set)
end

h_and_v_filled_coordinates = h_and_v_coordinate_sets.reduce({}) do |memo, coordinate_set|
  get_coordinate_keys(coordinate_set).each do |key|
    memo[key] || (memo[key] = 0)
    memo[key] += 1
  end

  memo
end

# Part 1
p h_and_v_filled_coordinates.count { |_, v| v > 1 }

all_filled_coordinates = coordinate_sets.reduce({}) do |memo, coordinate_set|
  get_coordinate_keys(coordinate_set).each do |key|
    memo[key] || (memo[key] = 0)
    memo[key] += 1
  end

  memo
end

# Part 2
p all_filled_coordinates.count { |_, v| v > 1 }
