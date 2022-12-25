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

  attr_reader :grid, :grid_height, :grid_width

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

  def initialize(grid, initial, final)
    @grid = grid

    @initial = initial
    @final = final

    @grid_width = raw_grid[0].length
    @grid_height = raw_grid.length

    @lcm = @grid_height * @grid_width

    # Cache is keyed by step, each step having a hash keys mapping every point to an array of storms at those points.
    # index: Non-modularized step
    # value: Hash
    #   key: point
    #   storm count
    @storms_cache = Array.new(@lcm) { new_step_hash }
    warm_storms_cache

    # key: manhattan distance
    # value: Array, sorted by step count (does this matter?)
    @cursor_store = Hash.new { |h, k| h[k] = Array.new }
  end

  def display_grid(grid)
    str = ''
    grid.each do |row|
      row.each do |value|
        str += value.to_s
      end
      str += "\n"
    end
    str
  end

  def new_step_hash
    Hash.new { |h, k| h[k] = Array.new }
  end

  def modularize_step(step)
    step % @lcm
  end

  def display_grid_at(step)
    storm_cache = @storms_cache[step]
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
          value = storms.count % 10
        end
        grid[y][x] = value
      end
    end

    display_grid(grid)
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

  def get_available_points(cursor)
    # What is the next set of points for the cursor step?
    current_step = cursor.step
    next_step = current_step + 1
    storms_grid = @storms_cache[modularize_step(next_step)]

    # Self, N, S, W, E
    potentially_available_points = [
      cursor.point,
      [cursor.point.first, cursor.point.last - 1],
      [cursor.point.first, cursor.point.last + 1],
      [cursor.point.first - 1, cursor.point.last],
      [cursor.point.first + 1, cursor.point.last]
    ]

    potentially_available_points_in_bounds = potentially_available_points.filter do |point|
      if point == @final || point == @initial
        true
      else
        point.first >= 0 && point.first < @grid_width && \
        point.last >= 0 && point.last < @grid_height
      end
    end

    available_points = potentially_available_points_in_bounds.filter do |point|
      storms_grid[point.last][point.first] == CELL_CLEAR
    end

    if available_points.count == 0
      raise 'wat'
    end

    available_points
  end

  def pull_from_storage
    # Find min manhattan distance.
    min_manhattan = @cursor_store.keys.min
    # Get first
    # @todo Does this need to be sorted? Does it matter?
    # Can insert in linear time if the steps are in order.
    @cursor_store[min_manhattan].shift
  end
end

class D24Cursor

  attr_accessor :point, :step, :final

  def initialize(initial, final, step = 0)
    @point = initial
    @final = final
    @step = step
  end

  def manhattan
    (@point.first - @final.first).abs + (@point.last - @final.last).abs
  end

  def new_child_at_present
    self.class.new(point, @final, @step + 1)
  end

  def new_child_at(new_point)
    self.class.new(new_point, @final, @step + 1)
  end

end


INITIAL = [0, -1]
FINAL = [raw_grid[0].length - 1, raw_grid.length]

nav = D24Nav.new(raw_grid, INITIAL, FINAL)
nav.push_to_storage(D24Cursor.new(INITIAL, FINAL))

10.times do |i|

  # Start the initial point, put in storage.
  cursor = nav.pull_from_storage

  # Look for available points at this step.
  # We either:
  # 1. Have to move
  #  - Create child cursor for available point with bumped steps.
  # 2. Have to stay
  #  - Create child cursor for available point with bumped steps.
  # 3. Can move or stay
  #  - Create child cursor for all available points with bumped steps.
  available_points = nav.get_available_points(cursor)

  # Reject any items that came to the same point with the same modular step index, which means they went in a cycle.
  # Each item could contain a history, which could be a hashmap:
  #  key: Point + modular cycle index
  #  value: count visited
  #
  # When do we break?
  # - We can stop if we reach the ending point. In which case, we should save the step count.
  # - Reject all items that exceed the step count. This is guaranteed to happen.

  print nav.display_grid_at(i)
  print "\n"
end