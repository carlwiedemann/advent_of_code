INPUT = File.readlines('./input_day_008.txt')
lines = INPUT.map(&:strip)

values = lines.map { _1.split(//).map(&:to_i) }

SIZE_X = values[0].length
SIZE_Y = values.length

# We need to look in the pos x, pos y, neg x, neg y

visible = Array.new(SIZE_Y) { Array.new(SIZE_X, 0) }

def is_edge?(x, y)
  is_x_edge?(x) || is_y_edge?(y)
end

def is_y_edge?(y)
  y == 0 || y == SIZE_Y - 1
end

def is_x_edge?(x)
  x == 0 || x == SIZE_X - 1
end

max_north_values = Array.new(SIZE_X, -1)
max_west_values = Array.new(SIZE_Y, -1)

SIZE_Y.times do |yi|
  SIZE_X.times do |xi|
    x = xi
    y = yi

    value = values[y][x]

    if is_edge?(x, y)
      visible[y][x] = 1
      if is_x_edge?(x)
        max_west_values[y] = value
      end
      if is_y_edge?(y)
        max_north_values[x] = value
      end
    else
      if value > max_west_values[y]
        visible[y][x] = 1
        max_west_values[y] = value
      end
      if value > max_north_values[x]
        visible[y][x] = 1
        max_north_values[x] = value
      end
    end
  end
end

max_south_values = Array.new(SIZE_X, -1)
max_east_values = Array.new(SIZE_Y, -1)

SIZE_Y.times do |yi|
  SIZE_X.times do |xi|
    x = SIZE_X - 1 - xi
    y = SIZE_Y - 1 - yi

    value = values[y][x]

    if is_edge?(x, y)
      visible[y][x] = 1
      if is_x_edge?(x)
        max_east_values[y] = value
      end
      if is_y_edge?(y)
        max_south_values[x] = value
      end
    else
      if value > max_east_values[y]
        visible[y][x] = 1
        max_east_values[y] = value
      end
      if value > max_south_values[x]
        visible[y][x] = 1
        max_south_values[x] = value
      end
    end
  end
end

# Part 1

sum = visible.reduce(0) do |memo, row|
  memo + row.reduce(&:+)
end

pp sum

# Part 2

max_product = 0

SIZE_Y.times do |y|
  SIZE_X.times do |x|
    if !is_edge?(x, y) && visible[y][x] == 1
      value = values[y][x]
      counts = Array.new(4, 0)
      # Next to north?
      j = y - 1
      while j >= 0
        counts[0] += 1
        break if values[j][x] >= value
        j -= 1
      end
      # Next to south?
      j = y + 1
      while j <= SIZE_Y - 1
        counts[1] += 1
        break if values[j][x] >= value
        j += 1
      end
      # Next to east?
      i = x + 1
      while i <= SIZE_X - 1
        counts[2] += 1
        break if values[y][i] >= value
        i += 1
      end
      # Next to west?
      i = x - 1
      while i >= 0
        counts[3] += 1
        break if values[y][i] >= value
        i -= 1
      end

      product = counts.reduce(&:*)
      if product > max_product
        max_product = product
      end
    end
  end
end

pp max_product
