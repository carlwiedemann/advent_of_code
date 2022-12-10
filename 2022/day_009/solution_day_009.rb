INPUT = File.readlines('./input_day_009.txt')
lines = INPUT.map(&:strip)

steps = lines.map do |line|
  parts = line.split(' ')

  {
    dir: parts[0],
    dist: parts[1].to_i
  }
end

DIFFS = {
  'U' => [0, 1],
  'D' => [0, -1],
  'L' => [-1, 0],
  'R' => [1, 0],
}

def get_next_tail(t, h)
  xd = h[0] - t[0]
  yd = h[1] - t[1]

  case
  when xd.abs <= 1 && yd.abs <= 1
    diff = [
      0,
      0
    ]
  when xd.abs == 2 && yd == 0 || xd == 0 && yd.abs == 2
    diff = [
      xd == 0 ? 0 : xd / xd.abs,
      yd == 0 ? 0 : yd / yd.abs
    ]
  else
    diff = [
      xd / xd.abs,
      yd / yd.abs
    ]
  end

  [
    t[0] + diff[0],
    t[1] + diff[1]
  ]
end

head_coors = [[0, 0]]
steps.each do |step|
  diff = DIFFS[step[:dir]]
  step[:dist].times.map do
    head_coors.push([
      head_coors.last[0] + diff[0],
      head_coors.last[1] + diff[1]
    ])
  end
end

# Part 1
tail_coors = head_coors.slice(1..).reduce([[0, 0]]) do |memo, h|
  memo.push(get_next_tail(memo.last, h))
end

pp tail_coors.uniq.count

# Part 2
8.times do
  head_coors = tail_coors
  tail_coors = head_coors.slice(1..).reduce([[0, 0]]) do |memo, h|
    memo.push(get_next_tail(memo.last, h))
  end
end

pp tail_coors.uniq.count
