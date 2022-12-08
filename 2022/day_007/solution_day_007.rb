INPUT = File.readlines('./input_day_007.txt')
lines = INPUT.map(&:strip)

MAX_DIR_SIZE = 100000

cursor = []

dirs = lines.reduce({}) do |memo, line|
  parts = line.split(' ')
  if parts[1] == 'cd'
    if parts[2] == '..'
      recent = memo[cursor]
      cursor = cursor.slice(0, cursor.length - 1)
      !memo[cursor].nil? || (memo[cursor] = 0)
      # We are done with the dir. Add to parent.
      memo[cursor] += recent
    else
      # We are entering a new dir, extend cursor.
      cursor = cursor + [parts[2]]
    end
  elsif /[0-9]+/ =~ parts[0]
    !memo[cursor].nil? || (memo[cursor] = 0)
    memo[cursor] += parts[0].to_i
  end

  memo
end

# Handle last.
while cursor.length > 0
  recent = dirs[cursor]
  cursor = cursor.slice(0, cursor.length - 1)
  if cursor.length > 0
    dirs[cursor] += recent
  end
end

# Part 1
sum = dirs.reduce(0) do |memo, (_dir, subtotal)|
  memo + ((subtotal < MAX_DIR_SIZE) ? subtotal : 0)
end

pp sum

# Part 2
MANDATORY_FREE_SPACE = 40000000
TOTAL_DISK_SPACE = 70000000

minimum_to_free = (dirs[["/"]] - MANDATORY_FREE_SPACE)

size = dirs.reduce(TOTAL_DISK_SPACE) do |memo, (_dir, subtotal)|
  (subtotal >= minimum_to_free && subtotal <= memo) ? subtotal : memo
end

pp size