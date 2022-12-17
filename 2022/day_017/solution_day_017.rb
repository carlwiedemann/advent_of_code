INPUT = File.read("#{File.dirname(__FILE__)}/input_day_017.txt")

ROCKS_RAW = "####

.#.
###
.#.

..#
..#
###

#
#
#
#

##
##"

AIR = '.'
ROCK = '#'

HEIGHT_INCREMENT = 3

ARENA_WIDTH = 7

module Aoc22d17
  class RockMachine
    attr_reader :arena

    def initialize(arena)
      @arena = arena
      @arena_copy = arena.dup.map do |row|
        row.dup.map do |v|
          v.dup
        end
      end
    end

    def self.display(points)
      str = ''
      points.length.times do |y_inv|
        y = points.length - y_inv - 1
        points[0].length.times do |x|
          str += points[y][x]
        end
        str += "\n"
      end

      str
    end

    def self.coors_from_shape(shape)
      coors = []
      shape.each_with_index do |row, y|
        row.each_with_index do |v, x|
          if v == ROCK
            coors.push([x, y])
          end
        end
      end
      coors
    end

    def display_arena
      self.class.display(@arena)
    end

    def collision?(coors, shape)
      collision = false
      coors.each do |coor|
        if shape[coor.last][coor.first] == ROCK
          collision = true
          break
        end
      end

      collision
    end

    def get_next_rock_position(existing_coors)
      potential_next_coors = existing_coors.map do |coor|
        [
          coor.first,
          coor.last - 1,
        ]
      end

      # Have we hit the floor?
      hit_floor = potential_next_coors.any? { _1.last == -1 }

      if hit_floor
        [:stuck, existing_coors]
      elsif collision?(potential_next_coors, @arena)
        [:stuck, existing_coors]
      else
        [:moved, potential_next_coors]
      end

    end

    def current_structure_height
      height = 0
      @arena.length.times do |y_inv|
        y = @arena.length - y_inv - 1
        row = @arena[y]
        if row.any? { _1 == ROCK }
          height = y + 1
          break
        end
      end
      height
    end

    def rock_coors_relative(i)
      self.class.coors_from_shape(ROCK_SHAPES[i % ROCK_SHAPES.count])
    end

    def initial_rock_position(i)
      base_y = current_structure_height + HEIGHT_INCREMENT
      base_x = 2
      rock_coors_relative(i).map do |coor|
        [
          base_x + coor.first,
          base_y + coor.last,
        ]
      end
    end

    def arena_clone
      @arena.reduce([]) do |memo, row|
        new_row = row.reduce([]) do |memo2, v|
          memo2.push(v)
        end
        memo.push(new_row)
      end
    end

    def grow_arena(diff)
      # Grow the arena
      diff.times do
        @arena.push(Array.new(ARENA_WIDTH) { AIR })
      end
    end

    def advance(i)

      grow_arena(rock_coors_relative(i).length)
      rock_coors = initial_rock_position(i)

      j = 0
      outcome = nil
      loop do
        arena = arena_clone

        rock_coors.each do |coor|
          arena[coor.last][coor.first] = ROCK
        end

        puts self.class.display(arena)
        puts "\n"

        (outcome, rock_coors) = get_next_rock_position(rock_coors)

        break if outcome == :stuck
        j += 1
      end

      if outcome == :stuck
        rock_coors.each do |coor|
          @arena[coor.last][coor.first] = ROCK
        end
        grow_arena([0, HEIGHT_INCREMENT - (@arena.length - 1 - current_structure_height)].max)
      end

      outcome

      # cave_is_full = false
      # falls_into_void = false
      #
      # loop do
      #   point_next = get_point_next(point)
      #
      #   falls_into_void = point_next.nil?
      #   break if falls_into_void
      #
      #   cave_is_full = point_next == INIT
      #   came_to_rest = point_next == point
      #   break if came_to_rest || cave_is_full
      #
      #   point = point_next
      # end
      #
      # if !falls_into_void
      #   @cave[y_relative(point.last)][x_relative(point.first)] = SAND
      #   sand_added = 1
      # else
      #   sand_added = 0
      # end
      #
      # [!falls_into_void && !cave_is_full, sand_added]

    end

  end

end

ROCK_SHAPES = ROCKS_RAW.split("\n\n").map do |rock|
  rock_lines = rock.split("\n")
  rock_y_max = rock_lines.count
  rock_x_max = rock_lines.max { _1.length }.length
  rock_shape = Array.new(rock_y_max) { Array.new(rock_x_max) { AIR } }
  rock_y_max.times do |y_inv|
    y = rock_y_max - y_inv - 1
    rock_x_max.times do |x|
      rock_shape[y][x] = rock_lines[y_inv][x]
    end
  end
  rock_shape
end

arena = Array.new(1) { Array.new(ARENA_WIDTH) { AIR } }

a = Aoc22d17::RockMachine.new(arena)

i = 0
loop do

  a.advance(i)

  break if i > 2
  i += 1
end

