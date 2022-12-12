INPUT = File.readlines('./input_day_012.txt')

map = INPUT.map do |line|
  line.strip.split(//)
end

module Aoc2022Day12
  class Navigator

    INT_MAX = 4611686018427387903
    STARTING_LETTER = 'S'
    ENDING_LETTER = 'E'

    def initialize(map)
      @map = map

      @distances = Hash.new { INT_MAX }
      @parents = Hash.new { nil }
      @denoted_and_unvisited = []
      @visited = Hash.new { false }

      denote_distance(starting_point, 0, nil)
    end

    def get_next_unvisited
      @denoted_and_unvisited.shift
    end

    def has_been_visited?(point)
      @visited[point]
    end

    def denote_visited(point)
      @visited[point] = true
    end

    def re_sort_denoted
      @denoted_and_unvisited.sort! { |a, b| get_distance(a) <=> get_distance(b) }
    end

    def denote_distance(point, distance, parent_point)
      @distances[point] = distance
      @parents[point] = parent_point
      @denoted_and_unvisited.push(point)
    end

    def get_distance(point)
      @distances[point]
    end

    def locate(letter)
      @map.each_with_index do |row, y|
        row.each_with_index do |value, x|
          if value == letter
            return [x, y]
          end
        end
      end
    end

    def starting_point
      @_starting_point ||= locate(STARTING_LETTER)
    end

    def ending_point
      @_ending_point ||= locate(ENDING_LETTER)
    end

    def reachable_neighbors(from_point)
      x = from_point.first
      y = from_point.last

      base_neighbors = [
        point_or_nil([x,     y - 1]),
        point_or_nil([x - 1, y]),
        point_or_nil([x + 1, y]),
        point_or_nil([x,     y + 1]),
      ]

      base_neighbors.compact.filter do |base_neighbor|
        get_value_diff(from_point, base_neighbor) < 2
      end
    end

    def get_value(point)
      raw_char = @map[point[1]][point[0]]

      case raw_char
      when STARTING_LETTER
        char = 'a'
      when ENDING_LETTER
        char = 'z'
      else
        char = raw_char
      end

      (char.ord - 'a'.ord).abs
    end

    def get_value_diff(a, b)
      get_value(b) - get_value(a)
    end

    def point_or_nil(point)
      x_in_range = point[0] >= 0 && point[0] < @map[0].length
      y_in_range = point[1] >= 0 && point[1] < @map.length

      x_in_range && y_in_range ? point : nil
    end

    def get_map
      @map.map do |row|
        row.join('')
      end.join("\n")
    end

    def get_marked_map(last_point)
      trail = get_trail(last_point)
      str = ''
      @map.each_with_index do |row, y|
        row.each_with_index do |value, x|
          if trail.include?([x, y])
            str += value.upcase
          else
            str += value
          end
        end
        str += "\n"
      end

      str
    end

    def get_trail(last_point = ending_point)
      point = last_point

      trail = []
      loop do
        parent = @parents[point]

        break if parent == starting_point

        trail.unshift(parent)
        point = parent
      end

      trail
    end

  end
end

nav = Aoc2022Day12::Navigator.new(map)

loop do
  point = nav.get_next_unvisited

  break if point.nil?

  unvisited_neighbors = nav.reachable_neighbors(point).reject do |neighbor|
    nav.has_been_visited?(neighbor)
  end

  re_sort = false
  unvisited_neighbors.each do |neighbor|

    potential_distance = nav.get_distance(point) + 1

    if potential_distance < nav.get_distance(neighbor)
      nav.denote_distance(neighbor, potential_distance, point)
      re_sort = true
    end
  end

  nav.re_sort_denoted if re_sort
  nav.denote_visited(point)
end

# Part 1
pp nav.get_trail.count + 1
