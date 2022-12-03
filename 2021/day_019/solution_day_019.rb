INPUT = File.readlines('./input_day_019.txt')
require 'digest'

point_sets = INPUT.map(&:strip).reduce([]) do |memo, line|
  if line[0..2] == '---'
    memo.push([])
  elsif line != ''
    memo.last.push(line.split(',').map(&:to_i))
  end

  memo
end

class CubeNineteen

  ##
  # The original raw points as provided by the input.
  #
  # @return [Array<Array<Integer>>]
  #
  attr_accessor :raw_points

  ##
  # Neighbor cubes.
  #
  # Neighbors are mutual and need to share an axis. Each affixed cube will have at least one neighbor.
  #
  # @return [Array<CubeNineteen>]
  #
  attr_accessor :neighbors

  ##
  # The affixed permutation variant, maps to a given index from possible permutations.
  #
  # @return [Integer]
  #
  attr_accessor :affixed_permutation

  ##
  # The affixed transformation.
  #
  # @return [Array<Integer>]
  #
  attr_accessor :affixed_transformation

  ##
  # Minimum number of points that requires to affix to a neighbor.
  #
  # @return [Integer]
  #
  MIN_POINTS = 12

  ##
  # Max number of sums that requires to affix to a neighbor.
  #
  # @return [Integer]
  #
  MAX_SUMS = 4

  ##
  # Identifier for positive X face/direction.
  #
  # @return [Integer]
  #
  X_PLUS = 0

  ##
  # Identifier for negative X face/direction.
  #
  # @return [Integer]
  #
  X_MINUS = 1

  ##
  # Identifier for positive Y face/direction.
  #
  # @return [Integer]
  #
  Y_PLUS = 2

  ##
  # Identifier for negative Y face/direction.
  #
  # @return [Integer]
  #
  Y_MINUS = 3

  ##
  # Identifier for positive Z face/direction.
  #
  # @return [Integer]
  #
  Z_PLUS = 4

  ##
  # Identifier for negative Z face/direction.
  #
  # @return [Integer]
  #
  Z_MINUS = 5

  ##
  # All directions/faces.
  #
  # @return [Array<Integer>] Directions.
  #
  DIRECTION_INDEXES = [
    X_PLUS,
    X_MINUS,
    Y_PLUS,
    Y_MINUS,
    Z_PLUS,
    Z_MINUS,
  ]

  ##
  # X axis identifier.
  #
  # @return [Integer]
  #
  X_AXIS = 0

  ##
  # Y axis identifier.
  #
  # @return [Integer]
  #
  Y_AXIS = 1

  ##
  # Z axis identifier.
  #
  # @return [Integer]
  #
  Z_AXIS = 2

  ##
  # The base permutation identifier.
  #
  # @return [Integer]
  #
  BASE_PERMUTATION = 0

  ##
  # Constructor.
  #
  # @param [Array<Array<Integer>>] raw_points Input points.
  #
  def initialize(raw_points)
    @raw_points = raw_points

    # Each neighbor will potentially be another one of the cubes.

    # Neighbors are mutually linked.
    @neighbors = Array.new(6)

    @affixed_transformation = [0, 0, 0]

    # Keys map to each face, aka direction.
    # +x 0
    # -x 1
    # +y 2
    # -y 3
    # +z 4
    # -z 5

    # A single face can only have a single neighbor.

  end

  ##
  # Whether the cube is affixed or not.
  #
  # @return [Boolean] true if affixed, false if not.
  #
  def is_affixed?
    !@affixed_permutation.nil?
  end

  ##
  # Rotates point around axis.
  #
  # @param [Integer] axis Axis identifier.
  # @param [Array<Integer>] point Point to rotate.
  #
  # @return [Array<Integer>] Rotated point.
  #
  def rotate_point_around_axis(axis, point)
    case axis
    when Z_AXIS
      new_point = [
        point[Y_AXIS],
        -point[X_AXIS],
        point[Z_AXIS]
      ]
    when X_AXIS
      new_point = [
        point[X_AXIS],
        point[Z_AXIS],
        -point[Y_AXIS]
      ]
    when Y_AXIS
      new_point = [
        -point[Z_AXIS],
        point[Y_AXIS],
        point[X_AXIS]
      ]
    else
      raise 'wat'
    end

    new_point
  end

  ##
  # Flips point on axis.
  #
  # @param [Integer] axis Axis identifier.
  # @param [Array<Integer>] point Point to flip.
  #
  # @return [Array<Integer>] Flipped point.
  #
  def flip_point_on_axis(axis, point)
    case axis
    when X_AXIS
      rotate_point_around_axis(Z_AXIS, rotate_point_around_axis(Z_AXIS, point))
    when Y_AXIS
      rotate_point_around_axis(Z_AXIS, rotate_point_around_axis(Z_AXIS, point))
    when Z_AXIS
      rotate_point_around_axis(Y_AXIS, rotate_point_around_axis(Y_AXIS, point))
    else
      raise 'wat'
    end
  end

  ##
  # Flips points around axis.
  #
  # @param [Integer] axis Axis identifier.
  # @param [Array<Array<Integer>>] points Points to flip.
  #
  # @return [Array<Array<Integer>>] points Flipped points.
  #
  def flip_axis(axis, points)
    points.map do |point|
      flip_point_on_axis(axis, point)
    end
  end

  ##
  # Rotates points around axis.
  #
  # @param [Integer] axis Axis identifier.
  # @param [Array<Array<Integer>>] points Points to rotate.
  #
  # @return [Array<Array<Integer>>] points Rotated points.
  #
  def rotate_axis(axis, points)
    points.map do |point|
      rotate_point_around_axis(axis, point)
    end
  end

  ##
  # Provide all permutations for a set of points around a given axis.
  #
  # @param [Integer] axis Axis identifier.
  # @param [Array<Array<Integer>>] points Points to rotate.
  def rotated_permutations(axis, points)
    permutations = []

    p0 = points
    permutations.push(p0)
    p1 = rotate_axis(axis, p0)
    permutations.push(p1)
    p2 = rotate_axis(axis, p1)
    permutations.push(p2)
    p3 = rotate_axis(axis, p2)
    permutations.push(p3)

    permutations
  end

  ##
  # Denote the cube as being affixed as the base permutation.
  #
  def as_base_affixed
    @affixed_permutation = BASE_PERMUTATION

    self
  end

  def all_permutations
    # There are 24 ways that we can receive the points.
    unless @_permutations
      permutations = []

      starting_points = @raw_points

      # Normal X, [0..3]
      permutations += rotated_permutations(X_AXIS, starting_points)
      # Flipped X [4..7]
      permutations += rotated_permutations(X_AXIS, flip_axis(X_AXIS, starting_points))

      # Normal Y
      base_y_points = rotate_axis(Z_AXIS, starting_points)
      permutations += rotated_permutations(Y_AXIS, base_y_points)
      # Flipped Y
      permutations += rotated_permutations(Y_AXIS, flip_axis(Y_AXIS, base_y_points))

      # Normal Z
      base_z_points = rotate_axis(Y_AXIS, starting_points)
      permutations += rotated_permutations(Z_AXIS, base_z_points)
      # Flipped Z
      permutations += rotated_permutations(Z_AXIS, flip_axis(Z_AXIS, base_z_points))

      @_permutations = permutations
    end

    @_permutations
  end

  def get_relative_points
    if @affixed_permutation.nil?
      raise 'not affixed'
    end

    all_permutations[@affixed_permutation]
  end

  def get_absolute_points
    if @affixed_permutation.nil?
      raise 'not affixed'
    end

    transform_points(all_permutations[@affixed_permutation], @affixed_transformation)
  end

  def get_available_direction_indexes
    # Directions not occupied by neighbors.
    DIRECTION_INDEXES.filter do |direction|
      @neighbors[direction].nil?
    end
  end

  def get_points_in_direction(direction, points)
    axis = direction_to_axis(direction)
    sign = direction_to_sign(direction)
    points.filter { |point| signs_match(point[axis], sign) }
  end

  def get_available_points_1d(points)
    get_available_direction_indexes.map do |direction_index|
      {
        direction_index: direction_index,
        points_1d: get_points_1d(direction_index, points)
      }
    end
  end

  def get_points_1d(direction, points)
    points_in_direction = get_points_in_direction(direction, points)
    axis = direction_to_axis(direction)
    # Return as sorted by least absolute value, i.e inner to outer.
    reduce_points_on_axis(axis, points_in_direction).sort do |a, b|
      a.abs <=> b.abs
    end
  end

  def reduce_points_on_axis(axis, points)
    points.map do |point|
      reduce_point_on_axis(axis, point)
    end
  end

  def reduce_point_on_axis(axis, point)
    point[axis]
  end

  def signs_match(a, b)
    a * b > 0
  end

  def direction_to_sign(direction)
    case direction
    when X_PLUS, Y_PLUS, Z_PLUS
      1
    when X_MINUS, Y_MINUS, Z_MINUS
      -1
    else
      raise 'wat'
    end
  end

  def direction_to_axis(direction)
    case direction
    when X_PLUS, X_MINUS
      X_AXIS
    when Y_PLUS, Y_MINUS
      Y_AXIS
    when Z_PLUS, Z_MINUS
      Z_AXIS
    else
      raise 'wat'
    end
  end

  def sorted_by_direction(direction_index, reference_points)
    axis = direction_to_axis(direction_index)
    reference_points.sort do |a, b|
      a[axis].abs <=> b[axis].abs
    end
  end

  ##
  # Can we append a neighbor? The neighbor must have at least 12 matching points.
  # Neighbors will generally have some face in common, which will be the opposite axis.
  # e.g.
  # -x maps to x
  # -y maps to y
  # -z maps to z
  #
  # This should save the affixed permutation.
  #
  # @param [CubeNineteen] affixed_neighbor
  #
  def append_to(affixed_neighbor)
    # Presume the instance is not affixed.
    # For every available 1d points on the affixed neighbor we should try all permutations on instance.
    # Matching entails at least 12 points (starting with the outermost, moving toward innermost)
    #
    # AFFIXED -> SELF
    # --+        +--
    #   |        |
    # --+        +--
    #  ^          ^
    # outermost should match innermost, then pull apart, ensuring overlap is at least 12.
    #
    # If all (or most?) differences in the point values are the same, we have a match.
    #
    # If a permutation matches, then we should save that particular permutation id on the instance and mark it as
    # affixed, and denote both neighbor values.
    found_match = false
    affixed_neighbor.get_available_points_1d(affixed_neighbor.get_relative_points).each do |item|
      affixed_points_1d = item[:points_1d]
      affixed_direction_index = item[:direction_index]

      complementary_direction_index = get_complementary_direction(affixed_direction_index)

      # Look at all permutations.
      all_permutations.each do |permutation_points|
        # The points in the direction for the given permutation.
        # Affixed will be inner to outer. Set permutation to be outer to inner.
        ordered_permutation_1d_points = self.get_points_1d(complementary_direction_index, permutation_points).reverse
        min_overlapped = [affixed_points_1d.count, ordered_permutation_1d_points.count].min
        if min_overlapped < MIN_POINTS
          # Continue to next.
        else
          # If we have at least the overlapped points, then we can compute the differences and denote whether they are
          # matching or not.
          while min_overlapped >= MIN_POINTS && !found_match
            last_affixed_points = affixed_points_1d.last(min_overlapped)
            first_permutated_points = ordered_permutation_1d_points.first(min_overlapped)
            # The sums should have some consistent values.
            sums = overlap_sums(last_affixed_points, first_permutated_points)
            if sums.count < MAX_SUMS
              # We have found the preliminary direction!

              # We will have permutation options based on the direction.
              reference_direction_points = affixed_neighbor.get_points_in_direction(affixed_direction_index, affixed_neighbor.get_relative_points)

              complementary_direction_index = get_complementary_direction(affixed_direction_index)

              overlapped_sorted_reference_points = sorted_by_direction(affixed_direction_index, reference_direction_points).last(min_overlapped)

              pivot_point = overlapped_sorted_reference_points[0]
              check_point = overlapped_sorted_reference_points[1]

              all_permutations.each_with_index do |permutation_points, permutation_index|
                sorted_permutation_points = sorted_by_direction(complementary_direction_index, get_points_in_direction(complementary_direction_index, permutation_points)).reverse.first(min_overlapped)
                permutation_pivot_point = sorted_permutation_points[0]
                permutation_check_point = sorted_permutation_points[1]

                # For this reference point, transform the points by the difference such that it matches the pivot point.
                local_transformation = get_transformation(permutation_pivot_point, pivot_point)

                # Does the check match?
                if transform_point(permutation_check_point, local_transformation) == check_point
                  # We matched! We have the permutation index!
                  found_match = true

                  # Affix this instance.
                  @affixed_transformation = add_points(local_transformation, affixed_neighbor.affixed_transformation)
                  @affixed_permutation = permutation_index

                  # Denote the neighbors.
                  affixed_neighbor.neighbors[affixed_direction_index] = self
                  self.neighbors[get_complementary_direction(affixed_direction_index)] = affixed_neighbor

                  # We found a match, so we can exit.
                  break
                end
              end

              # We found an overlap, so we can exit.
              break
            end
            # Decrease the overlap for the next iteration.
            min_overlapped -= 1
          end
        end

        break if found_match
      end

      break if found_match
    end

    found_match
  end

  def get_transformation(a, b)
    [
      b[0] - a[0],
      b[1] - a[1],
      b[2] - a[2],
    ]
  end

  def add_points(a, b)
    [
      a[0] + b[0],
      a[1] + b[1],
      a[2] + b[2],
    ]
  end

  def transform_point(point, transformation)
    [
      point[0] + transformation[0],
      point[1] + transformation[1],
      point[2] + transformation[2],
    ]
  end

  def transform_points(points, transformation)
    points.map do |point|
      transform_point(point, transformation)
    end
  end

  def overlap_sums(a, b)
    # Given two arrays, compute the differences between the successive elements.
    max = [a.count, b.count, 0].max.to_i
    i = 0
    diff = []
    while i < max
      diff.push(a[i].abs + b[i].abs)
      i += 1
    end

    diff.uniq
  end

  def get_complementary_direction(direction)
    case direction
    when X_PLUS
      X_MINUS
    when X_MINUS
      X_PLUS
    when Y_PLUS
      Y_MINUS
    when Y_MINUS
      Y_PLUS
    when Z_PLUS
      Z_MINUS
    when Z_MINUS
      Z_PLUS
    else
      raise 'wat'
    end
  end

  # This should pull out all of the points from all connected neighbors that are unique.
  def all_connected_points
    visited = {}

    # Queue self and add rest.
    queue = [self]

    all_points = []

    while queue.count > 0
      # @type [CubeNineteen]
      unvisited_neighbor = queue.shift

      visited[unvisited_neighbor.unique_id] = true

      all_points += unvisited_neighbor.get_absolute_points

      new_neighbors = unvisited_neighbor.neighbors.compact
      new_neighbors.each do |new_neighbor|
        if visited[new_neighbor.unique_id].nil?
          queue.push(new_neighbor)
        end
      end
    end

    all_points.uniq
  end

  def unique_id
    Digest::MD5.hexdigest(@raw_points.to_s)
  end

end


# LOGIC

cubes = point_sets.map do |point_set|
  CubeNineteen.new(point_set)
end

# Affix initial cube.
cubes[0].as_base_affixed

# @param [Array<CubeNineteen>] cubes
def unaffixed_cubes(cubes)
  cubes.reject do |cube|
    cube.is_affixed?
  end
end

# @param [Array<CubeNineteen>] cubes
def affixed_cubes(cubes)
  cubes.filter do |cube|
    cube.is_affixed?
  end
end

loop do

  unaffixed_cubes(cubes).each do |cube_to_affix|
    # Attempt to affix to any/all affixed cubes.
    affixed_cubes(cubes).each do |target_cube|
      if cube_to_affix.append_to(target_cube)
        # If we affixed, we can move on.
        break
      end
    end
  end

  if unaffixed_cubes(cubes).count == 0
    break
  end
end

# Part 1
pp cubes[0].all_connected_points.count

def manhattan_distance(a, b)
  (b[0] - a[0]).abs + (b[1] - a[1]).abs + (b[2] - a[2]).abs
end

# Part 2
max_distance = -1
cubes.each do |cube_i|
  cubes.each do |cube_j|
    distance = manhattan_distance(cube_i.affixed_transformation, cube_j.affixed_transformation)
    if distance > max_distance
      max_distance = distance
    end
  end
end

# Part 2
pp max_distance
