INPUT = File.readlines("#{File.dirname(__FILE__)}/input_day_019.txt")
lines = INPUT.map(&:strip)

TYPE_ORE = 0
TYPE_CLAY = 1
TYPE_OBSIDIAN = 2
TYPE_GEODE = 3

class BlueprintNode
  attr_reader :available_resources
  attr_reader :raw_blueprint
  attr_reader :staff
  attr_accessor :children

  # @return [BlueprintNode]
  attr_accessor :parent

  PRIORITIES = [
    TYPE_GEODE,
    TYPE_OBSIDIAN,
    TYPE_CLAY,
    TYPE_ORE
  ]

  def initialize(raw_blueprint, initial_staff, initial_resources = [0, 0, 0, 0])
    @raw_blueprint = raw_blueprint
    @staff = initial_staff
    @available_resources = initial_resources
    @children = []
  end

  def push_robot(type)
    @staff[type] += 1

    get_robot_cost(type).each_with_index do |v, i|
      @available_resources[i] -= v
    end
  end

  def get_robot_cost(type)
    @raw_blueprint[type]
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
    @staff.each_with_index do |count, i|
      @available_resources[i] += count
    end
  end

  def get_geode_robot_count
    @staff[TYPE_GEODE]
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
        ancestor.staff,
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
  robot_set = [1, 0, 0, 0]
  raw_blueprint = [
    [parts[6].to_i, 0, 0, 0],
    [parts[12].to_i, 0, 0, 0],
    [parts[18].to_i, parts[21].to_i, 0, 0],
    [parts[27].to_i, 0, parts[30].to_i, 0],
  ]
  BlueprintNode.new(raw_blueprint, robot_set)
end

MINUTES = 24
child_count = 0
MASTER_BLUEPRINTS.each do |master_blueprint|

  pp 'Building schedule...'
  schedule = BlueprintSchedule.new(master_blueprint)
  pp 'Done.'

  # MINUTES.times do
  # @type [Array<BlueprintNode>]
  queue = []
  depth = 0
  queue.push([master_blueprint, depth])

  max_geode_robots = 0

  # Let's say it doesn't make sense to accrue resources more than 40 each.
  max_resource_accrual = 40

  # @todo Limit the count based on how many geode robots it has built.
  # If it is less than 50% of max, then ignore.

  max_geode_blueprint = master_blueprint
  j = 1
  loop do
    data = queue.shift
    break if data.nil?
    # @type [BlueprintNode]
    blueprint = data[0]
    depth = data[1]

    if j % 100_000 == 0
      pp '--'
      pp j
      pp "child_count      #{child_count}"
      pp "max_geode_robots #{max_geode_robots}"
      pp "depth            #{depth}"
      pp "length           #{queue.length}"
    end

    break if depth > 23

    # It doesn't make sense to acquire resources in excess of 2x the first two robots and not build anything,
    # we should skip these.
    # next if blueprint.get_max_resource_count >= max_resource_accrual

    if depth > 21 && blueprint.get_geode_count < 1
      next
    end

    # if blueprint.get_geode_count > 1
    #   # It doesn't make sense to provision children if we won't be able to build any more geode bots.
    #   depth_remaining = 23 - depth - 1
    #   resources_at_remaining_depth = staff.map
    # end

    if blueprint.get_geode_count > max_geode_blueprint.get_geode_count
      max_geode_blueprint = blueprint
    end

    if blueprint.get_geode_robot_count > max_geode_robots
      max_geode_robots = blueprint.get_geode_robot_count
    end

    # What types can we build?
    types_we_can_build = schedule.types_for_resources(blueprint.available_resources)
    types_we_can_build.each do |possible_type|
      child = BlueprintNode.new(blueprint.raw_blueprint, blueprint.staff.dup, blueprint.available_resources.dup)
      child.bump_resources
      child.push_robot(possible_type)
      # unless child.get_geode_robot_count < max_geode_robots / 2
        child_count += 1
        child.parent = blueprint
        blueprint.children.push(child)
        queue.push([child, depth + 1])
      # end
    end
    # We can also choose to do nothing.
    # But only do this:
    # - If We can't build anything
    # We should also do this if the number of things that are able to be built is less than 2 and we don't have all robots yet.
    cant_build_anything = types_we_can_build.length == 0
    dont_have_all_robots = blueprint.staff.any?(0)
    if cant_build_anything || types_we_can_build.length < 2 && dont_have_all_robots
      child = BlueprintNode.new(blueprint.raw_blueprint, blueprint.staff.dup, blueprint.available_resources.dup)
      child.bump_resources
      # unless child.get_geode_robot_count < max_geode_robots / 2
        child_count += 1
        child.parent = blueprint
        blueprint.children.push(child)
        queue.push([child, depth + 1])
      # end
    end

    j += 1
  end

  pp '--'
  pp max_geode_blueprint.staff
  pp max_geode_blueprint.available_resources
  pp max_geode_blueprint.get_geode_count
  trail = max_geode_blueprint.get_ancestor_trail
  trail
  #   break
  # end

  break
end
