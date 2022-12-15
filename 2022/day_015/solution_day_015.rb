INPUT = File.readlines('./input_day_015.txt')
lines = INPUT.map(&:strip)

def get_manhattan(a, b)
  (a.first - b.first).abs + (a.last - b.last).abs
end

SENSORS = []
BEACONS = []
MANHATTANS = []

lines.each do |line|
  parts = line.split(' ')
  digit_mask = /[^0-9\-]/
  sensor = [
    parts[2].gsub(digit_mask, '').to_i,
    parts[3].gsub(digit_mask, '').to_i,
  ]
  beacon = [
    parts[8].gsub(digit_mask, '').to_i,
    parts[9].gsub(digit_mask, '').to_i,
  ]

  SENSORS.push(sensor)
  BEACONS.push(beacon)
  MANHATTANS.push(get_manhattan(beacon, sensor))
end

count = SENSORS.count

Y_VALUE = 2000000
BOUNDARY = 4000000

def get_cross_section(point, delta, manhattan)
  remain = (manhattan - delta.abs)
  [
    point.first - remain,
    point.first + remain
  ]
end

# Only consider sensors who are within the manhattan distance of the line.
cross_sections = SENSORS.each_with_index.reduce([]) do |memo, (sensor, i)|
  manhattan = MANHATTANS[i]
  delta = Y_VALUE - sensor.last

  memo + ((delta.abs <= manhattan) ? [get_cross_section(sensor, delta, manhattan)] : [])
end

# Part 1
sorted_cross_sections = cross_sections.sort { |a, b| a.first <=> b.first }

merged_cross_sections = sorted_cross_sections.reduce([]) do |memo, cross_section|
  if memo.count == 0
    memo.push(cross_section)
  else
    candidate = memo.first
    if candidate.last >= cross_section.first
      memo = [
        [
          candidate.first,
          [cross_section.last, candidate.last].max
        ]
      ]
    else
      memo.push(cross_section)
    end
  end

  memo
end

unavailable_count = merged_cross_sections.reduce(0) do |memo, section|
  memo + section.last - section.first
end

pp unavailable_count

# Part 2
count.times do |i|
  sensor = SENSORS[i]
  manhattan = MANHATTANS[i]

  x_base = sensor.first
  y_base = sensor.last

  valid_outside_points = manhattan.downto(0).reduce([]) do |memo, diff|
    y = diff + 1
    x = manhattan + 1 - y

    subset = [
      [x_base + x, y_base + y],
      [x_base - x, y_base + y],
      [x_base + x, y_base - y],
      [x_base - x, y_base - y],
    ]

    valid_subset = subset.uniq.filter do |outside_point|
      outside_point.first > 0 && outside_point.first <= BOUNDARY && \
      outside_point.last > 0 && outside_point.last <= BOUNDARY
    end

    memo.concat(valid_subset)
  end

  non_visible_points = valid_outside_points.filter do |point|
    visible = false

    count.times do |j|
      next if i == j
      visible = get_manhattan(point, SENSORS[j]) <= MANHATTANS[j]
      break if visible
    end

    !visible
  end

  if non_visible_points.count > 0
    pp non_visible_points.first.first * 4000000 + non_visible_points.first.last
    break
  end
end
