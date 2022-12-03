INPUT = File.readlines('./input_day_002.txt')
lines = INPUT.map(&:strip)

pairs = lines.map do |line|
  line.split(' ')
end

def value_for_first(pair)
  first = pair[0]
  case first
  when 'A'
    :rock
  when 'B'
    :paper
  when 'C'
    :scissors
  else
    raise 'wat'
  end
end

def value_for_second_part1(pair)
  second = pair[1]
  case second
  when 'X'
    :rock
  when 'Y'
    :paper
  when 'Z'
    :scissors
  else
    raise 'wat'
  end
end

def value_for_second_part2(pair)
  second = pair[1]
  case second
  when 'X'
    case value_for_first(pair)
    when :rock
      value = :scissors
    when :paper
      value = :rock
    when :scissors
      value = :paper
    else
      raise 'wat'
    end
  when 'Y'
    value = value_for_first(pair)
  when 'Z'
    case value_for_first(pair)
    when :rock
      value = :paper
    when :paper
      value = :scissors
    when :scissors
      value = :rock
    else
      raise 'wat'
    end
  else
    raise 'wat'
  end

  value
end

def score(them, me)
  if them == me
    3
  elsif them == :rock && me == :scissors
    0
  elsif them == :paper && me == :rock
    0
  elsif them == :scissors && me == :paper
    0
  else
    6
  end
end

def points(item)
  case item
  when :rock
    1
  when :paper
    2
  when :scissors
    3
  end
end

def assess_pair_part1(pair)
  first_result = value_for_first(pair)
  second_result = value_for_second_part1(pair)

  score(first_result, second_result)
end

def assess_pair_part2(pair)
  first_result = value_for_first(pair)
  second_result = value_for_second_part2(pair)

  score(first_result, second_result)
end

sum = 0
pairs.each do |pair|
  sum += assess_pair_part1(pair) + points(value_for_second_part1(pair))
end

pp sum

sum = 0
pairs.each do |pair|
  sum += assess_pair_part2(pair) + points(value_for_second_part2(pair))
end

pp sum

