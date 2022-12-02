INPUT = File.readlines('./input-day-012.txt')

# Represent graph as hash table.
lines = INPUT.map(&:strip)

graph = lines.reduce(Hash.new { |h, k| h[k] = [] }) do |memo, line|
  (a, b) = line.split('-')

  memo[a].push(b)

  memo[b].push(a)

  memo
end

STARTING_CAVE = 'start'
ENDING_CAVE = 'end'

small_caves = lines.reduce([]) do |memo, line|
  memo += line.split('-').filter do |i|
    i.upcase != i && i != STARTING_CAVE && i != ENDING_CAVE
  end
  memo.uniq
end

p small_caves

p graph


def is_small1(cave)
  cave.upcase != cave
end

def explore1(cave, graph, visited, path, all_paths, l)

  # Mark the cave as visited, only if the cave is a small cave.
  visited_on_this_trip = is_small1(cave) ? [cave] : []
  new_visited = visited + visited_on_this_trip

  # Append the cave to the path.
  new_path = path + [cave]

  # p '-' * l + new_path.join(',')

  all_child_caves = graph[cave]

  unvisited_child_caves = all_child_caves.filter do |child_cave|
    !visited.include?(child_cave)
  end

  if cave == ENDING_CAVE
    terminal = true
  else
    if unvisited_child_caves.count > 0
      terminal = false
      unvisited_child_caves.each do |child_cave|
        explore1(child_cave, graph, new_visited, new_path, all_paths, l + 1)
      end
    else
      terminal = true
    end
  end

  if terminal
    all_paths.push(new_path)
  end
end

all_paths = []

explore1(STARTING_CAVE, graph, [], [], all_paths, 0)

complete_paths = all_paths.filter { |path| path.last == ENDING_CAVE }

# Part 1
p complete_paths.count

def is_small2(cave)
  cave.upcase != cave
end

def explore2(cave, graph, visited, path, all_paths, allowed_twice, l)

  # Mark the cave as visited, only if the cave is a small cave.
  visited_on_this_trip = is_small2(cave) ? [cave] : []
  new_visited = visited + visited_on_this_trip

  # Append the cave to the path.
  new_path = path + [cave]

  # p '-' * l + new_path.join(',')

  all_child_caves = graph[cave]

  # Here's where we change for part 2. We filter out
  unvisited_child_caves = all_child_caves.filter do |child_cave|
    if child_cave == allowed_twice
      visited.count { |i| i == child_cave } < 2
    else
      !visited.include?(child_cave)
    end
  end

  if cave == ENDING_CAVE
    terminal = true
  else
    if unvisited_child_caves.count > 0
      terminal = false
      unvisited_child_caves.each do |child_cave|
        explore2(child_cave, graph, new_visited, new_path, all_paths, allowed_twice, l + 1)
      end
    else
      terminal = true
    end
  end

  if terminal
    all_paths.push(new_path)
  end
end

all_complete_paths = small_caves.map do |small_cave|
  all_paths = []
  explore2(STARTING_CAVE, graph, [], [], all_paths, small_cave, 0)
  complete_paths = all_paths.filter { |path| path.last == ENDING_CAVE }
  complete_paths.map { |path| path.join('-') }
end

# Part 2
p all_complete_paths.flatten.uniq.count
