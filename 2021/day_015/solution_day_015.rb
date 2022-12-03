INPUT = File.readlines('./input_day_015.txt')

INT_MAX = 4611686018427387903

map = INPUT.map do |line|
  line.strip.split('').map(&:to_i)
end

class NavigatorFifteen

  def initialize(map)
    @map = map

    @x_index = 0
    @y_index = 0

    @x_length = map[0].length
    @y_length = map.length

    # Keys will be points
    @distances = Hash.new { INT_MAX }
    @parents = Hash.new { nil }
    @denoted_and_unvisited = []
    @visited = Hash.new { false }
  end

  def get_parents
    @parents
  end

  def get_next_unvisited
    # Treat as a queue, get first item.
    @denoted_and_unvisited.shift
  end

  def has_been_visited?(point)
    @visited[point]
  end

  def denote_visited(point)
    @visited[point] = true
  end

  def resort_denoted
    @denoted_and_unvisited.sort! { |a, b| get_distance(a) <=> get_distance(b) }
  end

  def denote_distance(point, distance)
    @distances[point] = distance

    @denoted_and_unvisited.push(point)
  end

  def denote_parent(point, parent_point)
    @parents[point] = parent_point
  end

  def get_parent(point)
    @parents[point]
  end

  def get_distance(point)
    @distances[point]
  end

  def x_length
    @x_length
  end

  def y_length
    @y_length
  end

  def get_all_points
    points = []
    while @y_index < @y_length
      while @x_index < @x_length
        points.push(get_current_point)
        @x_index += 1
      end
      @y_index += 1
      @x_index = 0
    end

    reset
    points
  end

  def reset
    goto(starting_point)
  end

  def starting_point
    [0, 0]
  end

  def ending_point
    [@x_length - 1, @y_length - 1]
  end

  def size
    @x_length * @y_length
  end

  def goto(point)
    @x_index = point[0]
    @y_index = point[1]
  end

  def neighbors
    base = [
      point_or_nil([@x_index, @y_index - 1]),
      point_or_nil([@x_index - 1, @y_index]),
      point_or_nil([@x_index + 1, @y_index]),
      point_or_nil([@x_index, @y_index + 1]),
    ]

    base.compact
  end

  def get_current_value
    get_value(get_current_point)
  end

  def get_current_point
    [
      @x_index,
      @y_index
    ]
  end

  def get_value(point)
    @map[point[1]][point[0]]
  end

  def point_or_nil(point)
    x_in_range = point[0] >= 0 && point[0] < @x_length
    y_in_range = point[1] >= 0 && point[1] < @y_length

    x_in_range && y_in_range ? point : nil
  end

  def get_map
    @map.map do |row|
      row.join('')
    end.join("\n")
  end

end

nav = NavigatorFifteen.new(map)

big_map = []

0.upto(4) do |xi|
  0.upto(4) do |yi|
    points = nav.get_all_points
    points.each do |point|
      new_y = point[1] + yi * nav.y_length
      (big_map[new_y] = []) unless big_map[new_y]
      new_x = point[0] + xi * nav.x_length
      if yi > 0
        prev_value = big_map[new_y - nav.y_length][new_x] + 1
      elsif xi > 0
        prev_value = big_map[new_y][new_x - nav.x_length] + 1
      else
        prev_value = map[point[1]][point[0]]
      end
      big_map[new_y][new_x] = prev_value > 9 ? 1 : prev_value
    end
  end
end

# Un-comment this for part 2
nav = NavigatorFifteen.new(big_map)

# We need to keep track of a few things.
# First, we need to keep track of distances, as a hash.
# Next, we need to keep track of parents
# Next, we need to keep track of potential unvisited points.

finished = false

# Distance to the start is zero.
nav.denote_distance(nav.starting_point, 0)

until finished
  point = nav.get_next_unvisited
  point_distance = nav.get_distance(point)

  # Are we out of points to visit? Or have we reached the ending point? Then we may exit.
  if point.nil? || point == nav.ending_point
    finished = true
  else
    # Get the adjacent points.
    nav.goto(point)
    # Only get neighbors that we have not visited.
    neighbors_to_visit = nav.neighbors.reject { |neighbor| nav.has_been_visited?(neighbor) }

    resort = false
    neighbors_to_visit.each do |neighbor|

      # Calculate potential distance.
      neighbor_value = nav.get_value(neighbor)
      potential_distance = point_distance + neighbor_value

      # Set new distance if less.
      if potential_distance < nav.get_distance(neighbor)
        nav.denote_distance(neighbor, potential_distance)
        nav.denote_parent(neighbor, point)
        resort = true
      end
    end

    # If we denoted anything, we should resort it.
    nav.resort_denoted if resort

  end

  nav.denote_visited(point)
end


# Parents
# p nav.get_parents
p nav.get_distance(nav.ending_point)