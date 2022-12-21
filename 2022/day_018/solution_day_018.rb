INPUT = File.readlines("#{File.dirname(__FILE__)}/input_day_018.txt")
CUBES = INPUT.map do |line|
  line.split(',').map(&:to_i)
end

def side_in_common?(a, b)
  side_in_common = false
  [0, 1, 2].each do |i|
    a_reject = a.each_with_index.reject { |_, j| j == i }
    b_reject = b.each_with_index.reject { |_, j| j == i }
    if a_reject == b_reject && (a[i] - b[i]).abs == 1
      side_in_common = true
      break
    end
  end
  side_in_common
end

# Part 1
common_count = 0
CUBES.each do |a|
  CUBES.each do |b|
    next if a == b
    common_count += side_in_common?(a, b) ? 1 : 0
  end
end

part1 = CUBES.count * 6 - common_count
pp part1

# Part 2
MIN = 0
MAX = 19
RANGE = MIN..MAX

def get_neighbors(cube)
  base = [
    [cube[0] - 1, cube[1], cube[2]],
    [cube[0] + 1, cube[1], cube[2]],
    [cube[0], cube[1] - 1, cube[2]],
    [cube[0], cube[1] + 1, cube[2]],
    [cube[0], cube[1], cube[2] - 1],
    [cube[0], cube[1], cube[2] + 1],
  ]

  # Constrain to boundaries.
  base.filter do |c|
    RANGE === c[0] && RANGE === c[1] && RANGE === c[2]
  end
end

# Cubes as hash for O(1) lookup.
def as_hash(cubes)
  cubes.reduce(Hash.new { false }) do |memo, cube|
    memo[cube] = true
    memo
  end
end

# Whether cube is a border or not.
def is_border?(cube)
  cube[0] == MIN || cube[1] == MIN || cube[2] == MIN || \
  cube[0] == MAX || cube[1] == MAX || cube[2] == MAX
end

CUBES_HASH = as_hash(CUBES)

ALL_COORDINATES = []
20.times do |x|
  20.times do |y|
    20.times do |z|
      ALL_COORDINATES.push([x, y, z])
    end
  end
end

# Find difference between all coordinates and the solid cubes.
potential_air_cubes = ALL_COORDINATES - CUBES

# Remove all border items via bfs.
potential_air_cubes.each do |potential_air_cube|
  group = []
  if is_border?(potential_air_cube)
    group.push(potential_air_cube)

    queue = []
    queue.push(potential_air_cube)
    while queue.count > 0
      candidate = queue.shift
      neighbors = get_neighbors(candidate).reject do |n|
        already_seen = group.include?(n)
        is_a_cube = CUBES_HASH[n]
        already_seen || is_a_cube
      end
      neighbors.each do |n|
        group.push(n)
        queue.push(n)
      end
    end
  end

  potential_air_cubes = potential_air_cubes - group

  break if potential_air_cubes.all? { !is_border?(_1) }
end

# Do same logic on air cubes to find common neighbors, then calc diff from part 1.
common_count = 0
potential_air_cubes.each do |a|
  potential_air_cubes.each do |b|
    next if a == b
    common_count += side_in_common?(a, b) ? 1 : 0
  end
end

part2 = part1 - (potential_air_cubes.count * 6 - common_count)

pp part2
