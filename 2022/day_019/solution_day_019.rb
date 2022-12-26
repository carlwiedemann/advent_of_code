INPUT = File.readlines("#{File.dirname(__FILE__)}/input_day_019.txt")
lines = INPUT.map(&:strip)

TYPE_SKIP = -1
TYPE_ORE = 0
TYPE_CLAY = 1
TYPE_OBSIDIAN = 2
TYPE_GEODE = 3

class BlueprintNode
  attr_reader :available_resources
  attr_reader :robot_cost_schedule
  attr_reader :available_robots

  attr_accessor :children
  attr_accessor :did_skip
  attr_accessor :depth

  # @return [BlueprintNode]
  attr_accessor :parent

  PRIORITIES = [
    TYPE_GEODE,
    TYPE_OBSIDIAN,
    TYPE_CLAY,
    TYPE_ORE
  ]

  def initialize(robot_cost_schedule, initial_robots, initial_resources)
    @robot_cost_schedule = robot_cost_schedule
    @available_robots = initial_robots
    @available_resources = initial_resources
    @children = []
  end

  # @param [BlueprintNode] other_blueprint
  def greater_score_than?(other_blueprint)
    # greater_existing_member_score_than?(other_blueprint)
  end

  def greater_potential_member_score_than?(max_delta, other_blueprint)
    if other_blueprint == nil
      return true
    end

    # What is the number of geodes that can be built before the max delta?
    # If we can clearly create more geodes, then we win.
    my_max_capacity = @available_robots[TYPE_GEODE] * (max_delta - @depth)

    other_max_capacity = other_blueprint.available_robots[TYPE_GEODE] * (max_delta - other_blueprint.depth)

    my_max_capacity > other_max_capacity
  end

  def greater_existing_member_score_than?(other_blueprint)
    if other_blueprint == nil
      return true
    end

    # Look first at geode count, then geode robot count.
    score = @available_resources[TYPE_GEODE] <=> other_blueprint.available_resources[TYPE_GEODE]
    if score == 0
      score = @available_robots[TYPE_GEODE] <=> other_blueprint.available_robots[TYPE_GEODE]
      if score == 0
        score = @available_resources[TYPE_OBSIDIAN] <=> other_blueprint.available_resources[TYPE_OBSIDIAN]
        if score == 0
          score = @available_robots[TYPE_OBSIDIAN] <=> other_blueprint.available_robots[TYPE_OBSIDIAN]
          # if score == 0
          #   score = @available_resources[TYPE_CLAY] <=> other_blueprint.available_resources[TYPE_CLAY]
          #   if score == 0
          #     score = @available_robots[TYPE_CLAY] <=> other_blueprint.available_robots[TYPE_CLAY]
          #   end
          # end
        end
      end
    end

    score == 1
  end

  def push_robot(type)
    @available_robots[type] += 1

    get_robot_cost(type).each_with_index do |v, i|
      @available_resources[i] -= v
    end
  end

  def get_robot_cost(type)
    @robot_cost_schedule[type]
  end

  def can_build_robot?(robot_cost)
    self.class.resources_can_build_robot?(@available_resources, robot_cost)
  end

  def self.resources_can_build_robot?(resources, robot_cost)
    robot_cost.each_with_index.all? do |v, i|
      resources[i] >= v
    end
  end

  def bump_resources
    @available_robots.each_with_index do |count, i|
      @available_resources[i] += count
    end
  end

  def get_robot_count
    @available_robots.reduce(&:+)
  end

  def available_robot_types
    @available_robots.each_with_index.reduce([]) do |memo, (v, i)|
      if v > 0
        memo.push(i)
      end
      memo
    end
  end

  def get_geode_robot_count
    @available_robots[TYPE_GEODE]
  end

  def get_geode_count
    @available_resources[TYPE_GEODE]
  end

  def get_max_resource_count
    @available_resources.max
  end

  # @param [BlueprintSchedule] schedule
  def procure(schedule)

    # bump_resources

    # unless what_we_can_build.nil?
    #   push_robot(what_we_can_build)
    # end
  end

  def get_ancestor_trail

    trail = []
    ancestor = parent
    while !ancestor.nil?
      trail.push([
        ancestor.available_resources,
        ancestor.available_robots,
      ])
      ancestor = ancestor.parent
    end

    trail.reverse
  end

end

class BlueprintSchedule

  RESOURCE_LIMIT = 100

  # @param [BlueprintNode] blueprint
  def initialize(blueprint)
    # @type [BlueprintNode]
    @blueprint = blueprint
    build_schedule
  end

  TYPES = [
    TYPE_ORE,
    TYPE_CLAY,
    TYPE_OBSIDIAN,
    TYPE_GEODE
  ]

  TYPE_ENCODING = {
    TYPE_ORE => 0b0001,
    TYPE_CLAY => 0b0010,
    TYPE_OBSIDIAN => 0b0100,
    TYPE_GEODE => 0b1000,
  }

  TYPE_DECODING = TYPE_ENCODING.invert

  def types_for_resources(resources)
    encoded_types = @schedule[resource_key(resources)]
    # This could happen if we exceed the count, so we are limiting our options on purpose.
    if encoded_types.nil?
      []
    else
      decode_types(encoded_types)
    end
  end

  def resource_key(resources)
    resources.first(3)
  end

  def build_schedule
    @schedule = {}
    # For every combination of Ore, Clay, and Obsidian (because these are only ever used to build robots), what robots
    # are possible to build?
    RESOURCE_LIMIT.times do |index_ore|
      count_ore = index_ore
      RESOURCE_LIMIT.times do |index_clay|
        count_clay = index_clay
        RESOURCE_LIMIT.times do |index_obsidian|
          count_obsidian = index_obsidian
          resources = [
            count_ore,
            count_clay,
            count_obsidian,
            0
          ]
          available_types = TYPES.filter do |type|
            BlueprintNode.resources_can_build_robot?(resources, @blueprint.get_robot_cost(type))
          end
          @schedule[resource_key(resources)] = encode_types(available_types)
        end
      end
    end

    @schedule
  end

  def encode_types(types)
    !@_encode_types.nil? || (@_encode_types = {})

    return @_encode_types[types] unless @_encode_types[types].nil?

    encoded = types.reduce(0) do |memo, type|
      memo | TYPE_ENCODING[type]
    end

    @_encode_types[types] = encoded
  end

  def decode_types(encoded_types)
    !@_decode_types.nil? || (@_decode_types = {})

    return @_decode_types[encoded_types] unless @_decode_types[encoded_types].nil?

    decoded = TYPE_DECODING.reduce([]) do |memo, (k, v)|
      if k & encoded_types == k
        memo.push(v)
      end
      memo
    end

    @_decode_types[encoded_types] = decoded
  end
end

MASTER_BLUEPRINTS = lines.map do |line|
  parts = line.split
  initial_robots = [1, 0, 0, 0]
  initial_resources = [0, 0, 0, 0]
  raw_blueprint = [
    [parts[6].to_i, 0, 0, 0],
    [parts[12].to_i, 0, 0, 0],
    [parts[18].to_i, parts[21].to_i, 0, 0],
    [parts[27].to_i, 0, parts[30].to_i, 0],
  ]
  BlueprintNode.new(raw_blueprint, initial_robots, initial_resources)
end

MINUTES = 24

qualities = []

MASTER_BLUEPRINTS.each_with_index do |master_blueprint, blueprint_index|

  pp 'Building schedule...'
  schedule = BlueprintSchedule.new(master_blueprint)
  pp 'Done.'

  # MINUTES.times do
  # @type [Array<BlueprintNode>]
  queue = []
  master_blueprint.depth = 0
  queue.push(master_blueprint)

  max_geode_robots = 0
  max_geode_blueprint = master_blueprint

  max_existing_members_node_at_depth = {}
  max_potential_members_node_at_depth = {}

  j = 1
  loop do
    # @type [BlueprintNode]
    node = queue.shift
    break if node.nil?
    depth = node.depth

    break if depth > (MINUTES - 1)

    if j % 100_000 == 0
      pp '--'
      pp j
      # pp "max_geode_robots #{max_geode_robots}"
      pp "depth            #{depth}"
      pp "length           #{queue.length}"
    end

    # In a normal course of action what happens?
    # 1. We have a build phase, but the results are not online.
    # 2. We have a resource gathering phase.
    # 3. The results are now online for the next round (we can deduct).
    # 4. Repeat.

    # # If we don't have any geode robots by step 19, quit.
    # if depth > 19 && blueprint.get_geode_robot_count < 1
    #   next
    # end

    # Continue if we don't see the max existing members.
    if max_existing_members_node_at_depth[depth].nil?
      max_existing_members_node_at_depth[depth] = node
    end

    if max_existing_members_node_at_depth[depth].greater_existing_member_score_than?(node)
      next
    end

    # Continue if we don't see the max potential members.
    if max_potential_members_node_at_depth[depth].nil?
      max_potential_members_node_at_depth[depth] = node
    end

    if max_potential_members_node_at_depth[depth].greater_potential_member_score_than?(MINUTES - 1, node)
      next
    end

    # What types can we build?
    types_we_can_build = schedule.types_for_resources(node.available_resources)

    must_build = false

    # # Always build the first 2 robots you can afford.
    # if types_we_can_build.count > 0 && node.get_robot_count < 2
    #   # This represents that we have the resources to build at least 1.
    #   must_build = true
    # end

    # Always build the first robot of its kind.
    new_robots = types_we_can_build - node.available_robot_types
    if new_robots.count > 0
      types_we_can_build = new_robots
      must_build = true
    else
      # If we can potentially build a new robot, we are choosing to do so.
      # Otherwise, we should just consider building the most recent two robots.
      limit = 3
      if types_we_can_build.count > limit
        types_we_can_build = node.available_robot_types.last(limit) & types_we_can_build.last(limit)
      end
    end

    unless must_build
      types_we_can_build = types_we_can_build + [TYPE_SKIP]
    end

    # Two steps before the end to potentially add a new robot.
    if depth >= (MINUTES - 1) - 1
      # If the types we can build does *not* include a geode robot, then we should skip because this is no different than
      # any other scenario at this point.
      if types_we_can_build.include?(TYPE_GEODE)
        # If we can build a geode, then only consider that as an option.
        types_we_can_build = [TYPE_GEODE]
      else
        # If we cannot build geodes, then skip.
        types_we_can_build = [TYPE_SKIP]
      end
    end

    # Do not let the difference between the minimum robot count and the maximum robot count be greater than 5
    if types_we_can_build.count > 1
      min_count = node.available_robots.min
      max_count = min_count + 6
      # max_count = 5
      types_at_max = []
      node.available_robots.each_with_index do |count, type|
        if count >= max_count
          types_at_max.push(type)
        end
      end
      types_we_can_build = types_we_can_build - types_at_max
    end

    # This blueprint is now ready to generate children.
    types_we_can_build.each do |type|
      child_node = BlueprintNode.new(node.robot_cost_schedule, node.available_robots.dup, node.available_resources.dup)
      child_node.bump_resources
      if type != TYPE_SKIP
        child_node.push_robot(type)
        child_node.did_skip = false
      else
        child_node.did_skip = true
      end
      child_node.parent = node
      child_node.depth = depth + 1
      node.children.push(child_node)
      queue.push(child_node)
    end

    node.children.each do |child|
      # Track stats.
      if child.get_geode_count > max_geode_blueprint.get_geode_count
        max_geode_blueprint = child
      end

      if child.get_geode_robot_count > max_geode_robots
        max_geode_robots = child.get_geode_robot_count
      end
    end

    j += 1
  end

  # pp '--'
  # pp max_geode_blueprint.staff
  # pp max_geode_blueprint.available_resources

  # trail = max_geode_blueprint.get_ancestor_trail
  # trail
  # #   break
  # # end

  pp blueprint_label = (blueprint_index + 1)
  pp the_geode_count = max_geode_blueprint.get_geode_count
  pp '##'
  qualities.push(blueprint_label * the_geode_count)
end

pp qualities.reduce(&:+)

# IDEA 5: do not skip for more than 4 times in a row
# if blueprint.did_skip
#   skip_count = 1
#   # How many parents skipped?
#   target = blueprint.parent
#   loop do
#     break unless target.did_skip
#     skip_count += 1
#     target = target.parent
#   end
#
#   if skip_count > 3
#     next
#   end
# end

# IDEA 6: Only skip if we cannot build any more geode robots in the time remaining.
# Based on obsidian cost, since it is the most expensive.

