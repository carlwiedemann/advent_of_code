INPUT = File.readlines('./input_day_004.txt')
lines = INPUT.map(&:strip)

pairs = lines.map do |line|
  line.split(',').map do |string_pair|
    string_pair.split('-').map(&:to_i)
  end
end

# Part 1.
count = pairs.reduce(0) do |memo, pair|
  first = pair.first
  last = pair.last

  fully_contained = first.first >= last.first && first.last <= last.last ||
    last.first >= first.first && last.last <= first.last

  memo + (fully_contained ? 1 : 0)
end

pp count

# Part 2.
count = pairs.reduce(0) do |memo, pair|
  first = pair.first
  last = pair.last

  fully_contained = first.first >= last.first && first.last <= last.last ||
    last.first >= first.first && last.last <= first.last

  overlaps = first.last >= last.first && first.first <= last.first ||
    last.last >= first.first && last.first <= first.first

  memo + (fully_contained || overlaps ? 1 : 0)
end

pp count
