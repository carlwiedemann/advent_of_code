require_relative 'solution-day-020'

test1 = lambda do

  image = ImageTwenty.new([1, 0, 1, 0, 1, 0, 1, 0, 15, 0], [])

  digits = 8.to_s(2).rjust(9, 0.to_s).split(//).map(&:to_i)

  actual = image.get_next_value_from_grid(*digits)
  expected = 15

  if actual != expected
    raise "expected #{expected}"
  end

end

def assert(actual, expected)
  if actual != expected
    raise "expected #{expected}; received #{actual}"
  end
end

test2 = lambda do

  base_arg = Array.new(512, 0)

  image = ImageTwenty.new(base_arg, [])

  assert(image.default_for_next(0), 0)
  assert(image.default_for_next(1), 0)

  arg_a = base_arg.clone
  arg_a[0] = 1
  image = ImageTwenty.new(arg_a, [])

  assert(image.default_for_next(0), 1)
  assert(image.default_for_next(1), 0)

  arg_b = base_arg.clone
  arg_b[arg_b.count - 1] = 1
  image = ImageTwenty.new(arg_b, [])

  assert(image.default_for_next(0), 0)
  assert(image.default_for_next(1), 1)

end

test3 = lambda do

  image = ImageTwenty.new([], [])

  actual = image.count_grid([[1, 0, 1], [0, 1, 0], [1, 0, 1]])

  assert(actual, 5)
end

test1.call
test2.call
test3.call

p '### TESTS OK ###'