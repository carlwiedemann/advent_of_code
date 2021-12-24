INPUT = File.readlines('./input-day-014.txt')
lines = INPUT.map(&:strip)

template = lines.shift.to_s

# Remove empty.
lines.shift

rule_map = lines.reduce({}) do |memo, line|
  pair, insert = line.split(' -> ')
  memo[pair] = insert

  memo
end

initial_register = template.split('').each_cons(2).reduce(Hash.new { 0 }) do |memo, pair|
  memo[pair.join('')] += 1

  memo
end

def increment_register(letter_pair_register, rule_map)
  letter_pair_register.reduce(Hash.new { 0 }) do |memo, (original_pair, pair_count)|
    inner_letter = rule_map[original_pair]

    first_pair = original_pair[0] + inner_letter
    second_pair = inner_letter + original_pair[1]

    memo[first_pair] += pair_count
    memo[second_pair] += pair_count

    memo
  end
end

def score_register(register, template)
  distribution = register.reduce(Hash.new { 0 }) do |memo, (pair, count)|
    letters = pair.split('')
    memo[letters[0]] += count

    memo
  end

  # Take into account the final letter.
  distribution[template[-1]] += 1

  most = distribution.max { |(_, av), (_, bv)| av <=> bv }[1]
  least = distribution.min { |(_, av), (_, bv)| av <=> bv }[1]

  most - least
end

STEPS = 40

register = initial_register
STEPS.times do
  register = increment_register(register, rule_map)
end
p score_register(register, template)
