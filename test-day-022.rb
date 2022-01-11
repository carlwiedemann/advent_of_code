require_relative 'solution-day-022'

def assert(actual, expected)
  if actual != expected
    raise "expected #{expected}; received #{actual}"
  end
end

test1 = lambda do
  c = CuboidTwentyTwo.new([0, 0, 0], [2, 2, 2])
  assert(c.get_point_count, 27)

  c = CuboidTwentyTwo.new([1, 1, 1], [1, 1, 1])
  assert(c.get_point_count, 1)
end

test2 = lambda do
  c1 = CuboidTwentyTwo.new([0, 0, 0], [2, 2, 2])
  c2 = CuboidTwentyTwo.new([1, 1, 1], [3, 3, 3])
  c3 = CuboidTwentyTwo.new([3, 3, 3], [4, 4, 4])

  assert(c1.intersects?(c2), true)
  assert(c2.intersects?(c3), true)
  assert(c1.intersects?(c3), false)
end

test3 = lambda do
  c1 = CuboidTwentyTwo.new([0, 0, 0], [2, 2, 2])
  c2 = CuboidTwentyTwo.new([1, 1, 1], [3, 3, 3])

  assert(c1.get_intersection(c2).to_args, [[1, 1, 1], [2, 2, 2]])
end

test4 = lambda do
  c1 = CuboidTwentyTwo.new([0, 0, 0], [1, 1, 1])
  c2 = CuboidTwentyTwo.new([1, 1, 1], [2, 2, 2])
  c3 = CuboidTwentyTwo.new([0, 0, 0], [2, 2, 2])

  assert(c3.non_intersecting_point_count([c1, c2]), 12)
end

test5 = lambda do
  c1 = CuboidTwentyTwo.new([0, 0, 0], [1, 1, 1])
  c2 = CuboidTwentyTwo.new([1, 1, 1], [2, 2, 2])
  c3 = CuboidTwentyTwo.new([1, 1, 1], [2, 2, 2])
  c4 = CuboidTwentyTwo.new([1, 1, 1], [4, 4, 4])
  c5 = CuboidTwentyTwo.new([0, 0, 0], [2, 2, 2])

  assert(c5.non_intersecting_point_count([c1, c2, c3, c4]), 12)
end

test1.call
test2.call
test3.call
test4.call
test5.call

pp '### TESTS OK ###'