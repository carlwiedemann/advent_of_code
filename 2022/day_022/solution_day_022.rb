INPUT = File.readlines("#{File.dirname(__FILE__)}/input_day_022.txt")
raw_lines = INPUT

TURN_L = 'L'
TURN_R = 'R'

steps = raw_lines.pop.strip.split(//).reduce([]) do |memo, char|
  if char == TURN_L || char == TURN_R
    memo.push(char)
  else
    if memo.length == 0 || memo.last == TURN_L || memo.last == TURN_R
      memo.push(char)
    else
      memo.push("#{memo.pop}#{char}")
    end
  end
  memo
end

steps.map! do |step|
  if step == TURN_R || step == TURN_L
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
    FACE_UP => { TURN_L => FACE_LEFT, TURN_R => FACE_RIGHT },
    FACE_DOWN => { TURN_L => FACE_RIGHT, TURN_R => FACE_LEFT },
    FACE_LEFT => { TURN_L => FACE_DOWN, TURN_R => FACE_UP },
    FACE_RIGHT => { TURN_L => FACE_UP, TURN_R => FACE_DOWN },
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
      reconcile_position_and_direction_part_2(next_position, direction)
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

  def reconcile_position_and_direction_part_2(position, direction)
    reconcile_position_and_direction_part_1(position, direction)
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

    is_turn = [TURN_L, TURN_R].include?(step)

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

  nav.get_score
end

# print nav.display_map
# print "\n"
# print nav.display_map_with_trail
# pp nav.get_last_position
# pp nav.get_last_direction
# pp get_score_for(map, 1)
pp get_score_for(map, steps, 2)
