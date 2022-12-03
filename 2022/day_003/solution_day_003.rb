INPUT = File.readlines('./input_day_003.txt')
lines = INPUT.map(&:strip)

def get_score(letter)
  is_upper = letter.downcase != letter
  letter.downcase.ord - 97 + 1 + (is_upper ? 26 : 0)
end

# Part 1
sum = 0

lines.each do |line|
  length = line.length
  first_half = line[0..length / 2 - 1]
  second_half = line[(length / 2)..length]

  first_half.split(//).each do |char|
    if second_half.include?(char)
      sum += get_score(char)
      break
    end
  end
end

pp sum

# Part 2
sum = 0

lines.each_slice(3) do |group|
  group[0].split(//).each do |char|
    if group[1].include?(char) && group[2].include?(char)
      sum += get_score(char)
      break
    end
  end
end

pp sum