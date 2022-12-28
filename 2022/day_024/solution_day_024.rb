INPUT = File.readlines("#{File.dirname(__FILE__)}/input_day_024.txt")
lines = INPUT.map(&:strip)

lines.pop
lines.shift
raw_grid = lines.map do |line|
  parts = line.split(//)
  parts.pop
  parts.shift
  parts
end

class D24Nav
  CELL_STORM_LEFT = '<'
  CELL_STORM_RIGHT = '>'
  CELL_STORM_UP = '^'
  CELL_STORM_DOWN = 'v'
  CELL_CLEAR = '.'

  STORMS = [
    CELL_STORM_UP,
    CELL_STORM_DOWN,
    CELL_STORM_LEFT,
    CELL_STORM_RIGHT,
  ]

  def initialize(grid, endpoints)
    @grid = grid

    @endpoints = endpoints

    @grid_width = @grid[0].length
    @grid_height = @grid.length

    @lcm = @grid_height * @grid_width

    # Cache is keyed by step, each step having a hash keys mapping every point to an array of storms at those points.
    # index: Non-modularized step
    # value: Hash
    #   key: point
    #   storm count
    @storms_cache = Array.new(@lcm) { new_step_hash }
    warm_storms_cache

    @grid_cache = Array.new(@lcm)

    @available_points_cache = {}
  end

  def new_step_hash
    Hash.new { |h, k| h[k] = Array.new }
  end

  def modularize_step(step)
    step % @lcm
  end

  def get_storm_grid_at(step)
    cache_key = modularize_step(step)
    if @grid_cache[cache_key].nil?
      storm_cache = @storms_cache[modularize_step(step)]
      grid = Array.new(@grid_height) { Array.new(@grid_width) }
      @grid_height.times do |y|
        @grid_width.times do |x|
          point = [x, y]
          storms = storm_cache[point]
          if storms.nil? || storms.count == 0
            value = CELL_CLEAR
          elsif storms.count == 1
            value = storms[0]
          else
            value = storms.count
          end
          grid[y][x] = value
        end
      end

      @grid_cache[cache_key] = grid
    end

    @grid_cache[cache_key]
  end

  def warm_storms_cache
    # Build initial cache
    @grid.each_with_index do |row, y|
      row.each_with_index do |value, x|
        point = [x, y]
        if STORMS.include?(value)
          @storms_cache[0][point].push(value)
        end
      end
    end

    @lcm.times do |i|
      next_index = i + 1
      # For each point in the grid, determine the next point, pop and push.
      last_storm_cache = @storms_cache[i]
      next_storm_cache = new_step_hash
      last_storm_cache.each do |point, storms|
        storms.each do |storm|
          case storm
          when CELL_STORM_UP
            new_point = [point.first, (point.last - 1) % @grid_height]
          when CELL_STORM_DOWN
            new_point = [point.first, (point.last + 1) % @grid_height]
          when CELL_STORM_LEFT
            new_point = [(point.first - 1) % @grid_width, point.last]
          when CELL_STORM_RIGHT
            new_point = [(point.first + 1) % @grid_width, point.last]
          else
            raise 'wat'
          end
          next_storm_cache[new_point].push(storm)
        end
      end

      @storms_cache[next_index] = next_storm_cache
    end
  end

  # @param [Array<Integer>] point
  # @param [Integer] step
  def get_available_points(point, step)
    cache_key = [point, modularize_step(step)]
    if @available_points_cache[cache_key].nil?

      storms_grid = get_storm_grid_at(step)

      # Self, N, S, W, E
      potentially_available_points = [
        point,
        [point.first, point.last - 1],
        [point.first, point.last + 1],
        [point.first - 1, point.last],
        [point.first + 1, point.last]
      ]

      potentially_available_points_in_bounds = potentially_available_points.filter do |p|
        @endpoints.include?(p) || p.first >= 0 && p.first < @grid_width && p.last >= 0 && p.last < @grid_height
      end

      available_points = potentially_available_points_in_bounds.filter do |p|
        @endpoints.include?(p) || storms_grid[p.last][p.first] == CELL_CLEAR
      end

      @available_points_cache[cache_key] = available_points
    end

    @available_points_cache[cache_key]
  end
end

INITIAL = [0, -1]
FINAL = [raw_grid[0].length - 1, raw_grid.length]

nav = D24Nav.new(raw_grid, [INITIAL, FINAL])

# @param [D24Nav] nav
def get_steps(starting_point, ending_point, nav, step = 0)
  frontier = [starting_point]
  while frontier.count > 0
    new_frontier = []
    found_end = false
    frontier.each do |point|
      found_end = point == ending_point
      break if found_end
      nav.get_available_points(point, step).each do |adjacent_point|
        new_frontier.push(adjacent_point)
      end
      new_frontier.uniq!
    end
    break if found_end
    frontier = new_frontier
    step += 1
  end

  step
end

# Part 1.
final1 = get_steps(INITIAL, FINAL, nav)
pp (final1 - 1)

# Part 2.
final2 = get_steps(FINAL, INITIAL, nav, final1)
final3 = get_steps(INITIAL, FINAL, nav, final2)

pp (final3 - 1)