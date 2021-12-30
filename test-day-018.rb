require_relative 'solution-day-018'

test1 = lambda do
  sn1 = SnailFishNumber.from([1, 1])
  sn2 = SnailFishNumber.from([2, 2])

  sn3 = sn1.plus(sn2)

  if sn3.to_a != [[1, 1], [2, 2]]
    raise 'failed test 1'
  end
end

test2 = lambda do
  sn1 = SnailFishNumber.from([1, 1])
  sn2 = SnailFishNumber.from([2, 2])
  sn3 = SnailFishNumber.from([3, 3])
  sn4 = SnailFishNumber.from([4, 4])

  final = sn1.plus(sn2)
             .plus(sn3)
             .plus(sn4)

  if final.to_a != [[[[1, 1], [2, 2]], [3, 3]], [4, 4]]
    raise 'failed test 2'
  end
end

test3 = lambda do
  sn1 = SnailFishNumber.from([1, 1])
  sn2 = SnailFishNumber.from([2, 2])
  sn3 = SnailFishNumber.from([3, 3])
  sn4 = SnailFishNumber.from([4, 4])
  sn5 = SnailFishNumber.from([5, 5])

  final = sn1.plus(sn2)
             .plus(sn3)
             .plus(sn4)
             .plus(sn5)

  if final.to_a != [[[[3, 0], [5, 3]], [4, 4]], [5, 5]]
    p final.to_a
    raise 'failed test 3'
  end
end

test4 = lambda do
  sn1 = SnailFishNumber.from([1, 1])
  sn2 = SnailFishNumber.from([2, 2])
  sn3 = SnailFishNumber.from([3, 3])
  sn4 = SnailFishNumber.from([4, 4])
  sn5 = SnailFishNumber.from([5, 5])
  sn6 = SnailFishNumber.from([6, 6])

  final = sn1.plus(sn2)
             .plus(sn3)
             .plus(sn4)
             .plus(sn5)
             .plus(sn6)

  if final.to_a != [[[[5, 0], [7, 4]], [5, 5]], [6, 6]]
    p final.to_a
    raise 'failed test 4'
  end
end

test5 = lambda do
  sn1 = SnailFishNumber.from([[[0, [4, 5]], [0, 0]], [[[4, 5], [2, 6]], [9, 5]]])
  sn2 = SnailFishNumber.from([7, [[[3, 7], [4, 3]], [[6, 3], [8, 8]]]])
  sn3 = SnailFishNumber.from([[2, [[0, 8], [3, 4]]], [[[6, 7], 1], [7, [1, 6]]]])
  sn4 = SnailFishNumber.from([[[[2, 4], 7], [6, [0, 5]]], [[[6, 8], [2, 8]], [[2, 1], [4, 5]]]])
  sn5 = SnailFishNumber.from([7, [5, [[3, 8], [1, 4]]]])
  sn6 = SnailFishNumber.from([[2, [2, 2]], [8, [8, 1]]])
  sn7 = SnailFishNumber.from([2, 9])
  sn8 = SnailFishNumber.from([1, [[[9, 3], 9], [[9, 0], [0, 7]]]])
  sn9 = SnailFishNumber.from([[[5, [7, 4]], 7], 1])
  sn10 = SnailFishNumber.from([[[[4, 2], 2], 6], [8, 7]])

  final = sn1.plus(sn2)
             .plus(sn3)
             .plus(sn4)
             .plus(sn5)
             .plus(sn6)
             .plus(sn7)
             .plus(sn8)
             .plus(sn9)
             .plus(sn10)

  if final.to_a != [[[[8, 7], [7, 7]], [[8, 6], [7, 7]]], [[[0, 7], [6, 6]], [8, 7]]]
    p final.to_a
    raise 'failed test 5'
  end
end

test1.call
test2.call
test3.call
test4.call
test5.call

p '### TESTS OK ###'
