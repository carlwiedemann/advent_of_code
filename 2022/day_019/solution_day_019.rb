INPUT = File.readlines("#{File.dirname(__FILE__)}/input_day_019.txt")
lines = INPUT.map(&:strip)

TYPE_ORE = 0
TYPE_CLAY = 1
TYPE_OBSIDIAN = 2
TYPE_GEODE = 3

find_max = ->(line, line_index, minutes) do
  parts = line.split
  # Putting these in reverse order means that with the dfs we always go to the higher possible one first.
  cost_schedule = [
    [TYPE_GEODE, [parts[27].to_i, 0, parts[30].to_i, 0]],
    [TYPE_OBSIDIAN, [parts[18].to_i, parts[21].to_i, 0, 0]],
    [TYPE_CLAY, [parts[12].to_i, 0, 0, 0]],
    [TYPE_ORE, [parts[6].to_i, 0, 0, 0]],
  ]

  max = 0

  dfs = ->(resources, robots, minutes_left) do

    max_geodes_no_build = robots[TYPE_GEODE] * minutes_left + resources[TYPE_GEODE]
    if max_geodes_no_build > max
      max = max_geodes_no_build
    end

    # Arithmetic series sum to see maximum potential. This acts as a blacklist rather than a whitelist.
    # Before, we were using just the count at a given step and *including* it if it matched. This is stronger and limits
    # the options quite a bit more.
    max_potential_geodes = max_geodes_no_build + (minutes_left * (minutes_left - 1) / 2)
    if max_potential_geodes <= max
      return
    end

    # This seems to determine how many skips are required for a given robot cost.
    # It denotes that we will always seek to build, and that some number of things would take place in the meantime.
    turns_to_do = ->(robot_cost) do
      ts = resources.zip(robots, robot_cost).map do |type_resource_count, type_robot_count, type_cost|
        # For this particular resource, if we have more of it than the count of the bots, then we return 0
        if type_resource_count >= type_cost
          # If we have resources that are greater than costs, we shouldn't skip any turns, because it will mean we
          # can build right away.
          0
        else
          # Suppose we don't have as much resource as costs. How long should we collect?
          # If we have more than one bot:
          if type_robot_count > 0
            # How many turns to take.
            # Use reverse modulo trick to ensure that we keep a value up to the next zero remainder.
            (type_cost - type_resource_count + type_robot_count - 1) / type_robot_count
          else
            # If we do not possess any of the given bots for the given type, then we cannot build this at all.
            nil
          end
        end
      end

      # If anything was nil, then we will return nil, meaning that we cannot build the robot.
      # Otherwise, we return the max number of turns that are required to build the robot.
      if ts.all? { !_1.nil? }
        ts.max
      else
        nil
      end
    end

    transposed_schedules = cost_schedule.map { _1[1] }.transpose
    max_ore_cost = transposed_schedules[TYPE_ORE].max
    max_clay_cost = transposed_schedules[TYPE_CLAY].max
    max_obsidian_cost = transposed_schedules[TYPE_OBSIDIAN].max

    cost_schedule.each do |type, cost_for_type|
      # Do not build more robots if we have enough such that on any given turn any dependent robot cost is accommodated.
      # For each of these, if a type is proposed to be build, only build it if the number of robots of the particular
      # type is less than the max cost, which means that in a given turn we will not be able to produce the number
      # needed.
      case type
      when TYPE_ORE
        next if robots[type] >= max_ore_cost
      when TYPE_CLAY
        next if robots[type] >= max_clay_cost
      when TYPE_OBSIDIAN
        next if robots[type] >= max_obsidian_cost
      end

      turns = turns_to_do.call(cost_for_type)
      # This is a key factor is not taking turns that we don't have to take. There is no point in taking a turn if we
      # cannot build a bot in the allotted time.
      # By doing this we ensure that once a robot is built, the only decision we make is to build specific robots from
      # that point forward.
      if !turns.nil? && turns < minutes_left
        new_robots = robots.dup
        new_robots[type] += 1
        new_resources = resources.each_with_index.map do |resource, i|
          resource + (turns + 1) * robots[i] - cost_for_type[i]
        end
        dfs.call(new_resources, new_robots, minutes_left - turns - 1)
      end
    end
  end


  dfs.call([0, 0, 0, 0], [1, 0, 0, 0], minutes, true)

  [max, line_index]
end

# Part 1
quality = lines.each_with_index.reduce(0) do |memo, (line, line_index)|
  (max, line_index) = find_max.call(line, line_index, 24)
  memo + max * (line_index + 1)
end

pp quality

# Part 2
total = lines.first(3).each_with_index.reduce(1) do |memo, (line, line_index)|
  (max, _) = find_max.call(line, line_index, 32)
  memo * max
end

pp total
