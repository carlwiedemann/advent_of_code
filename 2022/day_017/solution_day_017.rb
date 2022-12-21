def find_repeat(a, min_size)
  loop_index = nil
  loop_count = nil
  t = 0
  loop do
    break if t >= a.count / 2 || !loop_index.nil?
    size = min_size.dup

    loop do
      t_range = t..(t + size - 1)
      h = t_range.last + 1
      h_range = h..(h + size - 1)

      if a[t_range] == a[h_range]
        loop_index = t_range.first
        loop_count = t_range.count
      end

      break if h_range.last >= a.count || !loop_index.nil?

      size += 1
    end

    t += 1
  end

  if loop_index.nil?
    nil
  else
    [loop_index, loop_count]
  end
end

INPUT = File.read("#{File.dirname(__FILE__)}/input_day_017.txt")
GAS_DIRECTIONS = INPUT.strip.split(//)

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
GAS_LEFT = '<'
GAS_RIGHT = '>'

HEIGHT_INCREMENT = 3

ARENA_WIDTH = 7

module Aoc22d17
  class RockMachine

    TRIM_SIZE = 100

    attr_reader :arena
    attr_reader :results
    attr_reader :absolute_step_i_height_i_map

    def initialize(arena)

      @arena = arena
      @arena_copy = arena.dup.map do |row|
        row.dup.map do |v|
          v.dup
        end
      end
      @frame_cursor = 0
      @height = 0

      @absolute_step_i_height_i_map = []

      @pattern_heights = []
      @pre_pattern_heights = []

      @results = []

      @trim_count = 0

      @top_egis = Hash.new { 0 }

      @initialize_pattern = :waiting
    end

    def self.display(points)
      str = ''
      points.count.times do |y_inv|
        y = points.count - y_inv - 1
        points[0].count.times do |x|
          str += points[y][x]
        end
        # str += "\n"
        str += " #{y}\n"
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

    def get_next_rock_position_fall(existing_coors)
      potential_next_coors = existing_coors.map do |coor|
        [
          coor.first,
          coor.last - 1,
        ]
      end

      hit_floor = potential_next_coors.any? { _1.last == -1 }

      if hit_floor
        [:stuck, existing_coors]
      elsif collision?(potential_next_coors, @arena)
        [:stuck, existing_coors]
      else
        [:moved, potential_next_coors]
      end
    end

    def get_next_rock_position_gas(egi, existing_coors)
      direction = GAS_DIRECTIONS[egi]
      xd = direction == GAS_LEFT ? -1 : 1
      potential_next_coors = existing_coors.map do |coor|
        [
          coor.first + xd,
          coor.last
        ]
      end

      # Have we hit the edges of the arena?
      hit_edge = potential_next_coors.any? { _1.first == -1 || _1.first == ARENA_WIDTH }

      if hit_edge
        [:stuck, existing_coors]
      elsif collision?(potential_next_coors, @arena)
        [:stuck, existing_coors]
      else
        [:moved, potential_next_coors]
      end
    end

    def get_current_structure_height
      height = 0
      @arena.count.times do |y_inv|
        y = @arena.count - y_inv - 1
        row = @arena[y]
        if row.any? { _1 == ROCK }
          height = y + 1
          break
        end
      end
      height
    end

    def get_effective_rock_index(i)
      i % ROCK_SHAPES.count
    end

    def rock_shape(eri)
      ROCK_SHAPES[eri]
    end

    def rock_coors_relative(eri)
      self.class.coors_from_shape(rock_shape(eri))
    end

    def initial_rock_position(eri)
      base_y = get_relative_height + HEIGHT_INCREMENT
      base_x = 2
      rock_coors_relative(eri).map do |coor|
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
      diff.times do
        @arena.push(Array.new(ARENA_WIDTH) { AIR })
      end
    end

    def auto_shrink_arena
      # Shrink top
      @arena = @arena[0..(get_relative_height + HEIGHT_INCREMENT - 1)]

      # if @arena.count > 2 * TRIM_SIZE
      #   @arena = @arena[TRIM_SIZE..]
      #   @trim_count += 1
      # end

    end

    def display_arena_frame(rock_coors)
      arena = arena_clone
      rock_coors.each do |coor|
        arena[coor.last][coor.first] = ROCK
      end
      puts self.class.display(arena)
      puts "\n"
    end

    def get_effective_gas_index
      @frame_cursor % GAS_DIRECTIONS.count
    end

    def advance(i, minimum_gas)

      eri = get_effective_rock_index(i)

      rock_height = rock_shape(eri).count
      grow_arena(rock_height)
      rock_coors = initial_rock_position(eri)

      # pp "start #{i}"
      # display_arena_frame(rock_coors)

      egi = get_effective_gas_index
      original_egi = egi.dup

      fall_outcome = nil
      loop do

        (_gas_outcome, rock_coors) = get_next_rock_position_gas(egi, rock_coors)
        @frame_cursor += 1

        # # Show arena
        # pp 'gas'
        # display_arena_frame(rock_coors)

        (fall_outcome, rock_coors) = get_next_rock_position_fall(rock_coors)

        # # Show arena
        # pp 'fall'
        # display_arena_frame(rock_coors)

        break if fall_outcome == :stuck
        egi = get_effective_gas_index
      end

      if fall_outcome == :stuck
        top_y_coor = get_relative_height - 1
        base_rock_y_coor = rock_coors[0].last

        potential_height_change = rock_height
        potential_diff = top_y_coor + 1 - base_rock_y_coor
        # pp 'potential_diff', potential_diff
        if potential_diff > 0
          height_change = potential_height_change - potential_diff
        else
          height_change = potential_height_change
        end
        if height_change > 0
          @height += height_change
        end

        @absolute_step_i_height_i_map[i] = @height - 1

        # We want to see results in:
        # - effective rock index
        # - effective gas index
        # - resulting row

        if @frame_cursor > minimum_gas && i > 0
          repeat_data = find_repeat(@arena.slice(0..top_y_coor), 20)

          unless repeat_data.nil?
            height_index_of_start = repeat_data.first
            step_index_of_start = @absolute_step_i_height_i_map.rindex(height_index_of_start)

            height_index_of_end = height_index_of_start + (repeat_data.last - 1)
            step_index_of_end = @absolute_step_i_height_i_map.rindex(height_index_of_end)

            relative_step_i_height_i_map = @absolute_step_i_height_i_map[step_index_of_start..step_index_of_end].map do |v|
              v - height_index_of_start
            end

            foo = {
              height_index_of_start: height_index_of_start,
              height_index_of_end: height_index_of_end,
              step_index_of_start: step_index_of_start,
              step_index_of_end: step_index_of_end,
              step_difference: (step_index_of_end - step_index_of_start),
              height_difference: height_index_of_end - height_index_of_start,
              arena_slice: @arena[height_index_of_start..height_index_of_end],
              # We need relative height map, not absolute
              relative_step_i_height_i_map: relative_step_i_height_i_map
            }
            # pp foo.except(:arena_slice)
            # puts self.class.display(foo[:arena_slice])
            return foo
          end
        end

        # Update arena.
        rock_coors.each do |coor|
          @arena[coor.last][coor.first] = ROCK
        end

        auto_shrink_arena

        return nil
      end

    end

    def get_relative_height
      @height - @trim_count * TRIM_SIZE
    end

    def get_height
      @height
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

# Part 1
arena = Array.new(HEIGHT_INCREMENT) { Array.new(ARENA_WIDTH) { AIR } }
a = Aoc22d17::RockMachine.new(arena)

i = 0
pattern_data = nil

[
  2022,
  1000000000000
].each do |step_part|

  loop do

    pattern_data = a.advance(i, [4 * GAS_DIRECTIONS.length, 50000].max)
    break unless pattern_data.nil?

    i += 1
  end

  step_width = pattern_data[:step_difference] + 1
  step_count_to_consider = step_part - (pattern_data[:step_index_of_start] + 1)
  pattern_count = step_count_to_consider / step_width
  remaining = step_count_to_consider % step_width

  base_height = pattern_data[:height_index_of_start] + 1

  pattern_height = pattern_count * (pattern_data[:height_difference] + 1)

  remaining_height = pattern_data[:relative_step_i_height_i_map][remaining]

  pp base_height + pattern_height + remaining_height
end

# 3130
# 1556521739139
