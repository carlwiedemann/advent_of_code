require 'digest'

INPUT = File.readlines('./input_day_022.txt')
lines = INPUT.map(&:strip)

class CuboidTwentyTwo
  X = 0
  Y = 1
  Z = 2

  attr_accessor :index
  attr_accessor :action
  attr_accessor :was_subtracted

  def initialize(min_point, max_point)
    @min_point = min_point
    @max_point = max_point
  end

  def to_args
    [@min_point, @max_point]
  end

  def get_point_count
    (x_max - x_min + 1) * (y_max - y_min + 1) * (z_max - z_min + 1)
  end

  def x_range
    [x_min, x_max]
  end

  def y_range
    [y_min, y_max]
  end

  def z_range
    [z_min, z_max]
  end

  def get_corners
    unless @_corners
      @_corners = []
      x_range.each do |x|
        y_range.each do |y|
          z_range.each do |z|
            @_corners.push([x, y, z])
          end
        end
      end
    end
    @_corners
  end

  def x_min
    @min_point[X]
  end

  def x_max
    @max_point[X]
  end

  def y_min
    @min_point[Y]
  end

  def y_max
    @max_point[Y]
  end

  def z_min
    @min_point[Z]
  end

  def z_max
    @max_point[Z]
  end

  # @param [CuboidTwentyTwo] cuboid Given cuboid.
  # @return [Boolean] `true` if any point is contained, `false` otherwise.
  def intersects?(cuboid)
    # Has edge overlap or Has non edge overlap.
    (self.contains_any_point?(cuboid) || cuboid.contains_any_point?(self)) || self.parent_of?(self.get_intersection(cuboid))
  end

  # @param [CuboidTwentyTwo] cuboid
  # @return [CuboidTwentyTwo]
  def get_intersection(cuboid)
    CuboidTwentyTwo.new([
                          [x_min, cuboid.x_min].max,
                          [y_min, cuboid.y_min].max,
                          [z_min, cuboid.z_min].max,
                        ],
                        [
                          [x_max, cuboid.x_max].min,
                          [y_max, cuboid.y_max].min,
                          [z_max, cuboid.z_max].min,
                        ])

  end

  # @param [CuboidTwentyTwo] cuboid Given cuboid.
  # @return [Boolean] `true` if any point is contained, `false` otherwise.
  def contains_any_point?(cuboid)
    cuboid.get_corners.reduce(false) do |memo, corner_point|
      unless memo
        memo = contains_point?(corner_point)
      end

      memo
    end
  end

  # @param [Array<Integer>] point
  # @return [Boolean] `true` if point is contained, `false` otherwise.
  def contains_point?(point)
    contains_x = point[X] >= x_min && point[X] <= x_max
    contains_y = point[Y] >= y_min && point[Y] <= y_max
    contains_z = point[Z] >= z_min && point[Z] <= z_max

    contains_x && contains_y && contains_z
  end

  def parent_of?(cuboid)
    cuboid.get_corners.reduce(true) do |memo, corner_point|
      memo && contains_point?(corner_point)
    end
  end

  def self.final_on_points(cuboids)
    on_count = 0

    cuboids.each do |present_cuboid|
      # If it is an on, add the initial.
      if present_cuboid.action == :on
        on_count += present_cuboid.get_point_count
      end

      # Now, we have to understand how the cuboid affected existing cuboids.
      if present_cuboid.index > 0
        # @type [Array<CuboidTwentyTwo>]
        existing_cuboids = cuboids.slice(Range.new(0, present_cuboid.index - 1))
      else
        # @type [Array<CuboidTwentyTwo>]
        existing_cuboids = []
      end

      # For all existing cuboids, we must determine where we have overlapped them, and depending on those overlaps
      # we must subtract those amounts from the amount we just added.
      #
      # If we overlap an "on" cuboid, then we must subtract that intersected portion which has not been subsumed by
      # any intermediate parent cuboids. Intermediate parents may be "on" or "off".
      #
      # We should consider these a stack.
      subtraction = 0

      existing_cuboids_stack = existing_cuboids.reverse
      existing_cuboids_stack.each do |existing_cuboid|
        if existing_cuboid.intersects?(present_cuboid)
          # The subject intersection is what we may be interested in subtracting.
          subject_intersection = existing_cuboid.get_intersection(present_cuboid)
          # Inherit the action.
          subject_intersection.action = existing_cuboid.action

          if subject_intersection.action == :on
            # We must reduce the subtraction by any intersection by intermediate cuboids.
            intermediate_cuboids = existing_cuboids.slice(Range.new(existing_cuboid.index + 1, present_cuboid.index - 1)).to_a
            base_to_subtract = subject_intersection.non_intersecting_point_count(intermediate_cuboids)
          else
            base_to_subtract = 0
          end

          subtraction += base_to_subtract
        end
      end

      on_count -= subtraction
    end

    on_count
  end

  # @param [Array<CuboidTwentyTwo>] cuboids
  def non_intersecting_point_count(cuboids)
    base_point_count = get_point_count

    intersecting_cuboids = cuboids.filter { _1.intersects?(self) }

    intersecting_cuboids.each.with_index do |intersecting_cuboid, i|
      remaining_cuboids = i < intersecting_cuboids.length - 1 ? intersecting_cuboids.slice(Range.new(i + 1, intersecting_cuboids.length - 1)).to_a : []

      intersection = get_intersection(intersecting_cuboid)

      base_point_count -= intersection.non_intersecting_point_count(remaining_cuboids)
    end

    base_point_count
  end

end

cuboids = lines.map.with_index do |line, i|
  action, rest = line.split
  (x_min, x_max), (y_min, y_max), (z_min, z_max) = rest.split(',').map do |part|
    _, range_str = part.split('=')
    range_str.split('..').map(&:to_i)
  end

  min_point = [
    x_min,
    y_min,
    z_min,
  ]
  max_point = [
    x_max,
    y_max,
    z_max,
  ]

  cuboid = CuboidTwentyTwo.new(min_point, max_point)
  cuboid.action = action.to_sym
  cuboid.index = i

  cuboid
end

pp CuboidTwentyTwo.final_on_points(cuboids)