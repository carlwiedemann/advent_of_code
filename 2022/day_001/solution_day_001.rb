INPUT = File.readlines('./input_day_001.txt')
lines = INPUT.map(&:strip)
lines.push("")

##
# First approach, add sums to an array, sort, then look at maxima: O(n * lg(n)).
#
first_approach = lambda do
  subtotal = 0
  subtotals = []

  lines.each do |line|
    if line == ""
      subtotals.push(subtotal)
      subtotal = 0
    else
      subtotal += line.to_i
    end
  end

  top = subtotals.max
  top3_sum = subtotals.max(3).reduce(&:+)

  [top, top3_sum]
end

##
# Second approach, curate top 3 in each iteration: O(n)
#
second_approach = lambda do
  subtotal = 0
  top3 = [0, 0, 0]

  lines.each do |line|
    if line == ""
      if subtotal > top3.min
        top3 = top3.push(subtotal).sort.last(3)
      end
      subtotal = 0
    else
      subtotal += line.to_i
    end
  end

  top = top3.last
  top3_sum = top3.reduce(&:+)

  [top, top3_sum]
end

##
# Third approach, use three different accumulators: O(n)
#
third_approach = lambda do
  max0 = 0
  max1 = 0
  max2 = 0

  subtotal = 0

  lines.each do |line|
    if line == ""
      # Manually check top 3.
      if subtotal > max0
        max2 = max1
        max1 = max0
        max0 = subtotal
      elsif subtotal > max1
        max2 = max1
        max1 = subtotal
      elsif subtotal > max2
        max2 = subtotal
      end
      subtotal = 0
    else
      subtotal += line.to_i
    end
  end

  top = max0
  top3_sum = max0 + max1 + max2

  [top, top3_sum]
end

pp first_approach.call
pp second_approach.call
pp third_approach.call