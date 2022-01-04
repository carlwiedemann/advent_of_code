require_relative 'solution-day-021'

def assert(actual, expected)
  if actual != expected
    raise "expected #{expected}; received #{actual}"
  end
end

test1 = lambda do

  d1 = DieTwentyOne.new

  expected_1 = [1, 2, 3]
  actual_1 = d1.roll_thrice

  expected_2 = [4, 5, 6]
  actual_2 = d1.roll_thrice

  assert(actual_1, expected_1)
  assert(actual_2, expected_2)

  d2 = DieTwentyOne.new(95)

  expected_1 = [96, 97, 98]
  actual_1 = d2.roll_thrice

  expected_2 = [99, 100, 1]
  actual_2 = d2.roll_thrice

  assert(actual_1, expected_1)
  assert(actual_2, expected_2)

end

test2 = lambda do

  p1 = PlayerTwentyOne.new(5)

  expected_1 = 8
  actual_1 = p1.move(3)

  expected_2 = 10
  actual_2 = p1.move(2)

  expected_3 = 3
  actual_3 = p1.move(13)

  assert(actual_1, expected_1)
  assert(actual_2, expected_2)
  assert(actual_3, expected_3)
end

test1.call
test2.call

p '### TESTS OK ###'