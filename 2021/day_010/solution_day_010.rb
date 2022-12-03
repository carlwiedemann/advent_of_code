INPUT = File.readlines('./input_day_010.txt')
LINES = INPUT.map(&:strip)

PAIRS = [
  '()',
  '[]',
  '{}',
  '<>',
]

SCORES1 = [
  3,
  57,
  1197,
  25137,
]

OPENERS = PAIRS.map { |pair| pair[0] }
CLOSERS = PAIRS.map { |pair| pair[1] }

def matches(first, second)
  OPENERS.include?(first) && OPENERS.index(first) == CLOSERS.index(second)
end

score = LINES.reduce(0) do |memo, line|

  stack = []
  first_bad_char = line.length.times.reduce(nil) do |memo2, i|
    unless memo2
      # The char may be an opener, or a closer.
      char = line[i]
      if OPENERS.include?(char)
        # Push onto the stack
        stack.push(char)
      else
        # If the char is a closer, it must match the last value on the stack.
        possible_opener = stack.last
        # If it does, pop the stack and keep going.
        if matches(possible_opener, char)
          stack.pop
        else
          memo2 = char
        end
      end
    end

    memo2
  end

  if first_bad_char
    memo += SCORES1[CLOSERS.index(first_bad_char)]
  end

  memo
end

# Part 1
p score

def score_set(set)
  set.reduce(0) do |memo, char|
    memo *= 5
    memo += (OPENERS.index(char) + 1)
    memo
  end
end

scores = LINES.reduce([]) do |memo, line|

  stack = []
  ok = true
  line.length.times do |i|
    # The char may be an opener, or a closer.
    char = line[i]
    if OPENERS.include?(char)
      # Push onto the stack
      stack.push(char)
    else
      # If the char is a closer, it must match the last value on the stack.
      possible_opener = stack.last
      # If it does, pop the stack and keep going.
      if matches(possible_opener, char)
        stack.pop
      else
        # If it does not, then the line is invalid
        ok = false
      end
    end
  end

  if ok
    score = score_set(stack.reverse)
  else
    score = 0
  end

  memo.push(score)

  memo
end

def median(arr)
  nonzeroes = arr.select { _1 > 0}
  nonzeroes.sort[nonzeroes.length/2]
end

# Part 2
p median(scores)