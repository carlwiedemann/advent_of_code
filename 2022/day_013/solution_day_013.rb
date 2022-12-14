INPUT = File.read('./input_day_013.txt')
pairs = INPUT.split(/\n\n/).map { |lines| lines.split(/\n/).map { |line| eval(line) } }

def order_status(left, right)
  if left.is_a?(Integer) && right.is_a?(Integer)
    if left == right
      status = :skip
    elsif left < right
      status = :valid
    else
      status = :invalid_lesser
    end
  elsif left.is_a?(Array) && right.is_a?(Array)
    status = :skip
    i = 0
    while i < left.count && i < right.count
      status = order_status(left[i], right[i])

      break if status != :skip
      i += 1
    end

    if status == :skip
      if left.count > i && right.count == i
        status = :invalid_out_of_items
      end
      if left.count == i && right.count > i
        status = :valid
      end
    end
  else
    status = order_status(Array(left), Array(right))
  end

  status
end

def in_order?(left, right)
  order_status(left, right) == :valid
end

# Part 1.
sum = pairs.each_with_index.reduce(0) do |memo, (pair, i)|
  memo + (in_order?(pair.first, pair.last) ? (i + 1) : 0)
end

pp sum

# Part 2.
d1, d2 = [[2]], [[6]]

all = pairs.reduce([d1, d2]) { |memo, pair| memo + [pair.first] + [pair.last] }

sorted = all.sort { |a, b| in_order?(a, b) ? -1 : 1 }

pp (sorted.index(d1) + 1) * (sorted.index(d2) + 1)
