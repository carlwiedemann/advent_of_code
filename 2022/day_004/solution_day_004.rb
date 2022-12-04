INPUT = File.readlines('./input_day_004.txt')
lines = INPUT.map(&:strip)

pairs = lines.map do |line|
  line.split(',').map do |string_pair|
    string_pair.split('-').map(&:to_i)
  end
end

# Part 1.
count = pairs.reduce(0) do |memo, pair|
  a = pair.first
  b = pair.last

  fully_contained = a.first >= b.first && a.last <= b.last ||
    b.first >= a.first && b.last <= a.last

  memo + (fully_contained ? 1 : 0)
end

pp count

# Part 2.
count = pairs.reduce(0) do |memo, pair|
  a = pair.first
  b = pair.last

  fully_contained = a.first >= b.first && a.last <= b.last ||
    b.first >= a.first && b.last <= a.last

  overlaps = a.last >= b.first && a.first <= b.first ||
    b.last >= a.first && b.first <= a.first

  memo + (fully_contained || overlaps ? 1 : 0)
end

pp count
