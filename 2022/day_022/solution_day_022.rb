INPUT = File.readlines("#{File.dirname(__FILE__)}/input_day_022.txt")
raw_lines = INPUT

TURN_LEFT = 'L'
TURN_RIGHT = 'R'
TURN_NULL = 'S'
TURN_REVERSE = 'V'

steps = raw_lines.pop.strip.split(//).reduce([]) do |memo, char|
  if char == TURN_LEFT || char == TURN_RIGHT
    memo.push(char)
  else
    if memo.length == 0 || memo.last == TURN_LEFT || memo.last == TURN_RIGHT
      memo.push(char)
    else
      memo.push("#{memo.pop}#{char}")
    end
  end
  memo
end

steps.map! do |step|
  if step == TURN_RIGHT || step == TURN_LEFT
    step
  else
    step.to_i
  end
end

raw_lines.pop

lines = raw_lines.map do |line|
  line.sub("\n", '')
end

MAP_HEIGHT = lines.length
MAP_WIDTH = lines.reduce(0) do |memo, line|
  if line.length > memo
    line.length
  else
    memo
  end
end

TILE_OPEN = '.'
TILE_WALL = '#'
TILE_VOID = ' '

# Alter map to get 1-indexed lines
lines.unshift(TILE_VOID * MAP_WIDTH)
map = lines.map do |line|
  full_line = TILE_VOID + line + (TILE_VOID * (MAP_WIDTH - line.length))
  full_line.split(//)
end

class D22nav

  attr_reader :trail

  def initialize(map)
    @map = map
    @trail = []
    starting_direction = FACE_RIGHT
    starting_position = [@map[1].index(TILE_OPEN), 1]
    push_to_trail(starting_position, starting_direction)
  end

  FACE_UP = '^'
  FACE_DOWN = 'v'
  FACE_LEFT = '<'
  FACE_RIGHT = '>'

  FACE_SCORE = {
    FACE_RIGHT => 0,
    FACE_DOWN => 1,
    FACE_LEFT => 2,
    FACE_UP => 3,
  }

  TURNS = {
    FACE_UP => { TURN_LEFT => FACE_LEFT, TURN_RIGHT => FACE_RIGHT, TURN_NULL => FACE_UP, TURN_REVERSE => FACE_DOWN },
    FACE_DOWN => { TURN_LEFT => FACE_RIGHT, TURN_RIGHT => FACE_LEFT, TURN_NULL => FACE_DOWN, TURN_REVERSE => FACE_UP },
    FACE_LEFT => { TURN_LEFT => FACE_DOWN, TURN_RIGHT => FACE_UP, TURN_NULL => FACE_LEFT, TURN_REVERSE => FACE_RIGHT },
    FACE_RIGHT => { TURN_LEFT => FACE_UP, TURN_RIGHT => FACE_DOWN, TURN_NULL => FACE_RIGHT, TURN_REVERSE => FACE_LEFT },
  }

  def get_next_position_and_direction(position, direction, part)
    case direction
    when FACE_UP
      next_position = [position.first, position.last - 1]
    when FACE_DOWN
      next_position = [position.first, position.last + 1]
    when FACE_LEFT
      next_position = [position.first - 1, position.last]
    when FACE_RIGHT
      next_position = [position.first + 1, position.last]
    else
      raise 'wat'
    end

    if part == 1
      reconcile_position_and_direction_part_1(next_position, direction)
    else
      reconcile_position_and_direction_part_2(position, next_position, direction)
    end
  end

  def position_is_invalid?(position)
    out_of_bounds_x = position.first > MAP_WIDTH || position.first < 1
    out_of_bounds_y = position.last > MAP_HEIGHT || position.last < 1
    out_of_bounds = out_of_bounds_y || out_of_bounds_x
    out_of_bounds ? true : @map[position.last][position.first] == TILE_VOID
  end

  def get_value(position)
    @map[position.last][position.first]
  end

  def push_to_trail(position, direction)
    @trail.push([position, direction])
  end

  def get_last_position
    @trail[get_last_trail_index][0]
  end

  def get_last_direction
    @trail[get_last_trail_index][1]
  end

  def denote_last_direction(turn)
    @trail[get_last_trail_index][1] = TURNS[get_last_direction][turn]
  end

  def get_score
    y = get_last_position.last
    x = get_last_position.first
    1000 * y + 4 * x + FACE_SCORE[get_last_direction]
  end

  def get_last_trail_index
    @trail.length - 1
  end

  def reconcile_position_and_direction_part_1(position, direction)
    if position_is_invalid?(position)
      loop do
        case direction
        when FACE_UP
          # Find opposite side.
          # Move down, in +y
          potential_position = [position.first, position.last + 1]
        when FACE_DOWN
          # Find opposite side.
          # Move up, in -y
          potential_position = [position.first, position.last - 1]
        when FACE_LEFT
          # Find opposite side.
          # Move right, in +x
          potential_position = [position.first + 1, position.last]
        when FACE_RIGHT
          # Find opposite side.
          # Move left, in -x
          potential_position = [position.first - 1, position.last]
        else
          raise 'wat'
        end

        break if position_is_invalid?(potential_position)
        position = potential_position
      end
    end

    [position, direction]
  end

  # @param [Integer] x
  # @param [Range] range_y
  def get_points_y(x, range_y)
    range_y.map do |y|
      [x, y]
    end
  end

  # @param [Integer] y
  # @param [Range] range_x
  def get_points_x(y, range_x)
    range_x.map do |x|
      [x, y]
    end
  end

  def get_points_map(from, to)
    Hash[from.zip(to)]
  end

  def reconcile_position_and_direction_part_2(last_position, next_position, last_direction)

    size = 4

    start_first = 1
    end_first = size

    start_second = end_first + 1
    end_second = size * 2

    start_third = end_second + 1
    end_third = size * 3

    start_fourth = end_third + 1
    end_fourth = size * 4

    range_first = start_first..end_first
    range_second = start_second..end_second
    range_third = start_third..end_third
    range_fourth = start_fourth..end_fourth

    sides = {
      :top => [range_third, range_first],
      :front => [range_third, range_second],
      :back => [range_first, range_second],
      :left => [range_second, range_second],
      :right => [range_fourth, range_third],
      :bottom => [range_third, range_third],
    }

    side_of_last_position = sides.reduce(nil) do |memo, (k, v)|
      if memo.nil?
        if v.first === last_position.first && v.last === last_position.last
          memo = k
        end
      end

      memo
    end

    top_up = get_points_map(get_points_x(start_first, range_third), get_points_x(start_second, range_first).reverse)
    top_left = get_points_map(get_points_y(start_third, range_first), get_points_x(start_second, range_second))
    top_right = get_points_map(get_points_y(end_third, range_first), get_points_y(end_fourth, range_third).reverse)
    left_down = get_points_map(get_points_x(end_second, range_second), get_points_y(start_third, range_third).reverse)
    back_left = get_points_map(get_points_y(start_first, range_second), get_points_x(end_third, range_fourth).reverse)
    back_down = get_points_map(get_points_x(end_second, range_first), get_points_x(end_third, range_third).reverse)
    front_right = get_points_map(get_points_y(end_third, range_second), get_points_x(start_third, range_fourth).reverse)

    wormholes = {
      [:top, FACE_RIGHT] => [top_right, FACE_LEFT],
      [:top, FACE_UP] => [ top_up, FACE_DOWN],
      [:top, FACE_LEFT] => [ top_left, FACE_DOWN],
      [:back, FACE_UP] => [ top_up.invert, FACE_DOWN],
      [:back, FACE_LEFT] => [ back_left, FACE_UP],
      [:back, FACE_DOWN] => [ back_down, FACE_UP],
      [:left, FACE_UP] => [ top_left.invert, FACE_RIGHT],
      [:left, FACE_DOWN] => [ left_down, FACE_RIGHT],
      [:front, FACE_RIGHT] => [ front_right, FACE_DOWN],
      [:bottom, FACE_LEFT] => [ left_down.invert, FACE_UP],
      [:bottom, FACE_DOWN] => [ back_down.invert, FACE_UP],
      [:right, FACE_UP] => [ front_right.invert, FACE_LEFT],
      [:right, FACE_RIGHT] => [ top_right.invert, FACE_LEFT],
      [:right, FACE_DOWN] => [ back_left.invert, FACE_RIGHT],
    }

    wormhole = wormholes[[side_of_last_position, last_direction]]

    next_direction = last_direction

    unless wormhole.nil?
      potential_next_position = wormhole[0][last_position]
      unless potential_next_position.nil?
        next_position = potential_next_position
        next_direction = wormhole[1]
      end
    end

    [next_position, next_direction]
  end

  def display_map
    display_points(@map)
  end

  def display_map_with_trail
    base_points = @map.dup
    @trail.each do |(position, direction)|
      base_points[position.last][position.first] = direction
    end
    display_points(base_points)
  end

  def display_points(grid)
    str = ''
    1.upto(grid.length - 1) do |y|
      1.upto(grid[0].length - 1) do |x|
        str += grid[y][x]
      end
      str += "\n"
    end
    str
  end
end

def get_score_for(map, steps, part)
  nav = D22nav.new(map)
  steps.each do |step|
    last_direction = nav.get_last_direction
    last_position = nav.get_last_position

    is_turn = [TURN_LEFT, TURN_RIGHT].include?(step)

    if is_turn
      nav.denote_last_direction(step)
    else
      step.times do
        (potential_position, potential_direction) = nav.get_next_position_and_direction(last_position, last_direction, part)
        value = nav.get_value(potential_position)

        break if value == TILE_WALL

        if value == TILE_OPEN
          nav.push_to_trail(potential_position, last_direction)
          last_position = potential_position
          last_direction = potential_direction
        end
      end
    end
  end

  print nav.display_map_with_trail

  nav.get_score
end

# print nav.display_map
# print "\n"
# pp nav.get_last_position
# pp nav.get_last_direction
# pp get_score_for(map, 1)
pp get_score_for(map, steps, 2)
