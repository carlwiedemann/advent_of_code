INPUT = File.readlines('./input_day_014.txt')
lines = INPUT.map(&:strip)

segments = lines.reduce([]) do |memo, line|
  segments = line.split(' -> ').each_cons(2).to_a.map do |coor_strs|
    coor_strs.map do |coor_str|
      coor_str.split(',').map(&:to_i)
    end
  end

  memo + segments
end

module Aoc2022Day14
  class SandMachine
    attr_reader :y_min
    attr_reader :y_max
    attr_reader :x_min
    attr_reader :x_max

    AIR = '.'
    STONE = '#'
    SAND = 'o'

    INIT = [500, 0]

    def x_relative(x_raw)
      x_raw - @x_min
    end

    def y_relative(y_raw)
      y_raw - @y_min
    end

    def initialize(segments)
      points_raw = segments.reduce([]) { |memo, v| memo + [v.first] + [v.last] }

      @x_min = points_raw.min { |a, b| a.first <=> b.first }.first
      @x_max = points_raw.max { |a, b| a.first <=> b.first }.first
      @y_min = 0
      @y_max = points_raw.max { |a, b| a.last <=> b.last }.last

      x_width = @x_max - @x_min + 1
      y_width = @y_max - @y_min + 1

      @cave = Array.new(y_width) { Array.new(x_width, AIR) }

      segments.each do |segment|
        xi = [segment.first.first, segment.last.first].min
        xf = [segment.first.first, segment.last.first].max

        yi = [segment.first.last, segment.last.last].min
        yf = [segment.first.last, segment.last.last].max

        (yi..yf).map do |y|
          (xi..xf).map do |x|
            @cave[y_relative(y)][x_relative(x)] = STONE
          end
        end
      end

      @raw_map = @cave.dup
    end

    def is_air?(point)
      @cave[y_relative(point.last)][x_relative(point.first)] == AIR
    end

    def get_point_next(point)
      frontier = [
        [point.first - 1, point.last + 1],
        [point.first,     point.last + 1],
        [point.first + 1, point.last + 1],
      ]

      out_of_bounds = frontier.any? do |frontier_point|
        frontier_point.first > @x_max || frontier_point.first < @x_min || frontier_point.last > @y_max || frontier_point.last < @y_min
      end

      case
      when out_of_bounds
        nil
      when is_air?(frontier[1])
        frontier[1]
      when is_air?(frontier[0])
        frontier[0]
      when is_air?(frontier[2])
        frontier[2]
      else
        point
      end
    end

    def advance
      cave_is_full = false
      falls_into_void = false

      point = INIT
      loop do
        point_next = get_point_next(point)

        falls_into_void = point_next.nil?
        break if falls_into_void

        cave_is_full = point_next == INIT
        came_to_rest = point_next == point
        break if came_to_rest || cave_is_full

        point = point_next
      end

      if !falls_into_void
        @cave[y_relative(point.last)][x_relative(point.first)] = SAND
        sand_added = 1
      else
        sand_added = 0
      end

      [!falls_into_void && !cave_is_full, sand_added]
    end
  end
end

# Part 1
sand_machine = Aoc2022Day14::SandMachine.new(segments)
i = 0
loop do
  (continue, sand_added) = sand_machine.advance
  i += sand_added
  break unless continue
end
pp i

# Part 2
# Since sand piles have 45 degree inclines, use height to determine width.
segments.push([
  [sand_machine.x_min - sand_machine.y_max, sand_machine.y_max + 2],
  [sand_machine.x_max + sand_machine.y_max, sand_machine.y_max + 2],
])

sand_machine = Aoc2022Day14::SandMachine.new(segments)
i = 0
loop do
  (continue, sand_added) = sand_machine.advance
  i += sand_added
  break unless continue
end
pp i