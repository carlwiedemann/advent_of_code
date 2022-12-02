INPUT = File.readlines('./input-day-009.txt')

map = INPUT.map do |line|
  line.strip.split('').map(&:to_i)
end

class Navigator

  WALL = 9

  def initialize(map)
    @map = map
    @x_length = map[0].length
    @x_index = 0
    @y_length = map.length
    @y_index = 0
  end

  def reset(x = 0, y = 0)
    @x_index = x
    @y_index = y
  end

  def next
    not_finished = true
    @x_index += 1
    if @x_index == @x_length
      @y_index += 1
      @x_index = 0
      if @y_index == @y_length
        not_finished = false
      end
    end

    not_finished
  end

  def pos_at(x, y)
    @map[y][x]
  end

  def north_coords
    [@x_index, @y_index - 1]
  end

  def south_coords
    [@x_index, @y_index + 1]
  end

  def east_coords
    [@x_index + 1, @y_index]
  end

  def west_coords
    [@x_index - 1, @y_index]
  end

  def north
    (@y_index == 0) ? WALL : pos_at(*north_coords)
  end

  def south
    (@y_index == @y_length - 1) ? WALL : pos_at(*south_coords)
  end

  def east
    (@x_index == @x_length - 1) ? WALL : pos_at(*east_coords)
  end

  def west
    (@x_index == 0) ? WALL : pos_at(*west_coords)
  end

  def is_low
    current_value = pos_at(@x_index, @y_index)
    current_value < north && current_value < south && current_value < east && current_value < west ? current_value : nil
  end

  def surroundings
    base = [
      {
        coords: north_coords,
        value: north,
      },
      {
        coords: south_coords,
        value: south,
      },
      {
        coords: east_coords,
        value: east,
      },
      {
        coords: west_coords,
        value: west,
      }
    ]

    base.select { |v| v[:value] < WALL }
  end

  def get_basins
    queue = []

    queue.push(surroundings)

    original_coords = [@x_index, @y_index]

    basin_items = {}
    while queue.length > 0
      set = queue.shift
      set.each do |item|
        basin_items[item[:coords].to_s] = item
        reset(*item[:coords])
        queue.push(surroundings.select { |surrounding| basin_items[surrounding[:coords].to_s].nil? })
      end
    end

    reset(*original_coords)

    basin_items
  end

end

nav = Navigator.new(map)

lows = []
loop do
  potential = nav.is_low
  if potential
    lows.push(potential)
  end
  break unless nav.next
end

# Part 1
p lows.map { |i| i + 1 }.sum

nav.reset

basins = []
loop do
  potential = nav.is_low
  if potential
    basins.push(nav.get_basins.length)
  end
  break unless nav.next
end

# Part 2
p basins.sort.last(3).reduce(:*)