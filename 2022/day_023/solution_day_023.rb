INPUT = File.readlines("#{File.dirname(__FILE__)}/input_day_023.txt")
lines = INPUT.map(&:strip)

raw_map = lines.map do |line|
  line.split(//)
end

class D23nav

  attr_reader :map, :elf_points

  SPACE_OPEN = '.'
  SPACE_ELF = '#'

  NORTH = :north
  SOUTH = :south
  EAST = :east
  WEST = :west

  BUFFER = 2

  def initialize(map)
    @map = map
    @elf_points = get_elf_positions(@map)
    @points_to_consider = @elf_points.dup
    buffer_all

    @direction_precedence = [
      NORTH,
      SOUTH,
      WEST,
      EAST,
    ]
  end

  def shift_directions
    @direction_precedence.push(@direction_precedence.shift)
  end

  def get_elf_positions(grid)
    positions = []
    grid.each_with_index do |row, y|
      row.each_with_index do |value, x|
        if value == SPACE_ELF
          positions.push([x, y])
        end
      end
    end
    positions
  end

  def buffer_all
    buffer = 0
    if @map.first.any? { _1 == SPACE_ELF } || @map.last.any? { _1 == SPACE_ELF }
      buffer = 2
    elsif @map.first(2).last.any? { _1 == SPACE_ELF } || @map.last(2).first.any? { _1 == SPACE_ELF }
      buffer = 1
    else
      @map.each do |row|
        if row.first == SPACE_ELF || row.last == SPACE_ELF
          buffer = 2
        elsif row.first(2).last == SPACE_ELF || row.last(2).first == SPACE_ELF
          buffer = 1
        end
      end
    end

    if buffer > 0
      @elf_points = buffer_points(@elf_points, buffer)
      @map = buffer_grid(@map, buffer)
      @points_to_consider = buffer_points(@points_to_consider, buffer)
    end
  end

  def buffer_points(points, incr)
    points.map do |point|
      [
        point.first + incr,
        point.last + incr
      ]
    end
  end

  def buffer_grid(raw_grid, incr)
    width = raw_grid.first.length

    buffered_grid = raw_grid.map do |row|
      new_row = row.dup
      incr.times do
        new_row.unshift(SPACE_OPEN)
        new_row.push(SPACE_OPEN)
      end
      new_row
    end

    incr.times do
      buffered_grid.unshift(Array.new(width + 2 * incr, SPACE_OPEN))
      buffered_grid.push(Array.new(width + 2 * incr, SPACE_OPEN))
    end

    buffered_grid
  end

  def display(grid)
    str = ''
    grid.each do |row|
      row.each do |v|
        str += v
      end
      str += "\n"
    end
    str
  end

  def points_n(point)
    y = point.last - 1
    [
      [point.first - 1, y],
      [point.first, y],
      [point.first + 1, y],
    ]
  end

  def points_s(point)
    y = point.last + 1
    [
      [point.first - 1, y],
      [point.first,     y],
      [point.first + 1, y],
    ]
  end

  def points_w(point)
    x = point.first - 1
    [
      [x, point.last - 1],
      [x, point.last],
      [x, point.last + 1],
    ]
  end

  def points_e(point)
    x = point.first + 1
    [
      [x, point.last + 1],
      [x, point.last],
      [x, point.last - 1],
    ]
  end

  def get_neighbors(point)
    [
      [point.first - 1, point.last - 1],
      [point.first, point.last - 1],
      [point.first + 1, point.last - 1],
      [point.first + 1, point.last],
      [point.first - 1, point.last],
      [point.first - 1, point.last + 1],
      [point.first, point.last + 1],
      [point.first + 1, point.last + 1],
    ]
  end

  def get_value_at(point)
    row = @map[point.last]
    row[point.first]
  end

  def set_value_at(point, value)
    @map[point.last][point.first] = value
  end

  def should_move?(point)
    should_move = false
    get_neighbors(point).each do |neighbor_point|
      if get_value_at(neighbor_point) == SPACE_ELF
        should_move = true
        break
      end
    end
    should_move
  end

  def move_point(point, new_point)
    set_value_at(point, SPACE_OPEN)
    set_value_at(new_point, SPACE_ELF)
  end

  def can_move_in_direction?(direction, point)
    case direction
    when NORTH
      frontier = points_n(point)
    when SOUTH
      frontier = points_s(point)
    when EAST
      frontier = points_e(point)
    when WEST
      frontier = points_w(point)
    else
      raise 'wat'
    end

    frontier.all? do |frontier_point|
      get_value_at(frontier_point) == SPACE_OPEN
    end
  end

  def moved_point(direction, point)
    case direction
    when NORTH
      [
        point.first,
        point.last - 1
      ]
    when SOUTH
      [
        point.first,
        point.last + 1
      ]
    when EAST
      [
        point.first + 1,
        point.last
      ]
    when WEST
      [
        point.first - 1,
        point.last
      ]
    else
      raise 'wat'
    end
  end

  def redraw

    proposed_positions = Hash.new { |h,k| h[k] = Array.new }

    while @points_to_consider.length > 0
      point = @points_to_consider.shift
      if should_move?(point)
        @direction_precedence.each do |direction|
          if can_move_in_direction?(direction, point)
            new_point = moved_point(direction, point)
            proposed_positions[new_point].push(point)
            break
          end
        end
      end
    end

    # Analyze proposed positions to determine which should move and which should not.
    allowed_proposed_positions = proposed_positions.filter do |_, v|
      v.count == 1
    end

    # Move the points to the proposed positions.
    all_new_points = []
    all_old_points_that_moved = []
    allowed_proposed_positions.each do |new_point, old_points_that_moved|
      old_point_that_moved = old_points_that_moved[0]
      move_point(old_point_that_moved, new_point)
      all_new_points.push(new_point)
      all_old_points_that_moved.push(old_point_that_moved)
    end

    @elf_points = @elf_points - all_old_points_that_moved + all_new_points
    @points_to_consider = @elf_points.dup

    # Buffer the map, adjust elf points.
    buffer_all

    # Return the count of new points, which are the points that moved.
    all_new_points.length
  end

end

# Part 1.
nav = D23nav.new(raw_map)
10.times do
  nav.redraw
  nav.shift_directions
end

max_x = 0
max_y = 0
min_x = 100_000
min_y = 100_000
nav.elf_points.each do |(x, y)|
  max_x = x if x > max_x
  min_x = x if x < min_x
  max_y = y if y > max_y
  min_y = y if y < min_y
end

product = (max_x - min_x + 1) * (max_y - min_y + 1) - nav.elf_points.count
pp product

# Part 1.
nav = D23nav.new(raw_map)
i = 1
loop do
  break if nav.redraw == 0
  nav.shift_directions
  i += 1
end

pp i
