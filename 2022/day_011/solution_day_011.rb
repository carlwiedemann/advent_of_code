INPUT = File.read('./input_day_011.txt')

monkeys = INPUT.split(/\n\n/).map do |chunk|
  parts = chunk.split(/\n/).map(&:strip)
  {
    stack: parts[1].split(':').last.split(', ').map(&:to_i),
    op: parts[2].split(':')[1].strip,
    div: parts[3].split(' ').last.to_i,
    if_true: parts[4].split(' ').last.to_i,
    if_false: parts[5].split(' ').last.to_i,
  }
end.to_a

considerations = Array.new(monkeys.count, 0)

20.times do |j|
  monkeys.each_index do |i|

    current_monkey = monkeys[i]

    while current_monkey[:stack].count > 0
      considerations[i] += 1
      old = current_monkey[:stack].shift
      new = 0

      eval(current_monkey[:op].to_s)

      worry = new / 3

      part = (worry % current_monkey[:div] == 0) ? :if_true : :if_false

      monkeys[current_monkey[part]][:stack].push(worry)
    end
  end
end

pp considerations
pp considerations.max(2).reduce(&:*)