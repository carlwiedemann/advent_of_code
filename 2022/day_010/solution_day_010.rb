INPUT = File.readlines('./input_day_010.txt')
lines = INPUT.map(&:strip)

CHECKINS = [20, 60, 100, 140, 180, 220]

x_reg = 1
saved = []

CRT_HEIGHT = 6
CRT_WIDTH = 40
crt = Array.new(CRT_HEIGHT) { Array.new(CRT_WIDTH, ' ')}
crt_x = 0
crt_y = 0

cycle = 0

lines.each do |line|
  parts = line.split(' ')

  parts.count.times do
    cycle += 1

    crt[crt_y][crt_x] = '#' if [x_reg - 1, x_reg, x_reg + 1].include?(crt_x)

    crt_x += 1
    crt_x %= CRT_WIDTH
    crt_y += (crt_x == 0) ? 1 : 0

    saved.push(x_reg * cycle) if CHECKINS.include?(cycle)
  end

  x_reg += parts[1].to_i if parts.count == 2
end

# Part 1
pp saved.reduce(&:+)

# Part 2
puts crt.map(&:join)