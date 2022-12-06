INPUT = File.readlines('./input_day_006.txt')
lines = INPUT.map(&:strip)

line = lines[0]

[4, 14].each do |count|
  line.length.times do |i|
    if i > count && line[i - (count - 1)..i].chars.uniq.count == count
      pp i + 1
      break
    end
  end
end
