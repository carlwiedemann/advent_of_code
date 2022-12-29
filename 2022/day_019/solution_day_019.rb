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

  def initialize(robot_cost_schedule, initial_robots, initial_resources)
    @robot_cost_schedule = robot_cost_schedule
    @available_robots = initial_robots
    @available_resources = initial_resources
  end

  def push_robot(type)
    if type != TYPE_SKIP
      @available_robots[type] += 1

      get_robot_cost(type).each_with_index do |v, i|
        @available_resources[i] -= v
      end
    end
  end

  def get_max_cost_for_type(type)
    @robot_cost_schedule.transpose[type].max
  end

  def get_robot_cost(type)
    @robot_cost_schedule[type]
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

  def get_geode_robot_count
    @available_robots[TYPE_GEODE]
  end

  def get_geode_count
    @available_resources[TYPE_GEODE]
  end

  def available_robot_types
    available_robot_types = []
    @available_robots.each_with_index do |count, type|
      if count > 0
        available_robot_types.push(type)
      end
    end
    available_robot_types
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

  def get_buildable_types_for_resources(resources)
    @schedule[resource_key(resources)]
  end

  def resource_key(resources)
    resources.first(3)
  end

  def build_schedule
    @schedule = {}
    double_resource_limit = RESOURCE_LIMIT * 2
    # For every combination of Ore, Clay, and Obsidian (because these are only ever used to build robots), what robots
    # are possible to build?
    double_resource_limit.times do |index_ore|
      count_ore = index_ore
      double_resource_limit.times do |index_clay|
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
          @schedule[resource_key(resources)] = available_types
        end
      end
    end

    @schedule
  end
end

MASTER_BLUEPRINTS = lines.map do |line|
  parts = line.split
  initial_robots = [1, 0, 0, 0]
  initial_resources = [0, 0, 0, 0]
  robot_cost_schedule = [
    [parts[6].to_i, 0, 0, 0],
    [parts[12].to_i, 0, 0, 0],
    [parts[18].to_i, parts[21].to_i, 0, 0],
    [parts[27].to_i, 0, parts[30].to_i, 0],
  ]
  BlueprintNode.new(robot_cost_schedule, initial_robots, initial_resources)
end

MINUTES = 24

# @param [BlueprintNode] blueprint
# @param [BlueprintSchedule] schedule
def dfs(schedule, blueprint, minutes_left, reset = false)
  !@_times.nil? || (@_times = 0)
  if reset
    @_times = 0
  end
  @_times += 1
  if @_times % 100000 == 0
    pp "Scanned      #{@_times}"
  end
  if minutes_left >= 0
    types_to_build = schedule.get_buildable_types_for_resources(blueprint.available_resources) + [TYPE_SKIP]

    # Do not build more robots if we have enough such that on any given turn any dependent robot cost is accommodated.
    types_to_build = types_to_build.filter do |type_to_build|
      # For each of these, if a type is proposed to be build, only build it if the number of robots of the particular
      # type is less than the max cost, which means that in a given turn we will not be able to produce the number
      # needed.
      case type_to_build
      when TYPE_ORE, TYPE_CLAY, TYPE_OBSIDIAN
        blueprint.available_robots[type_to_build] < blueprint.get_max_cost_for_type(type_to_build)
      else
        true
      end
    end

    # If we can build a geode, it should be the only option we pick.
    if types_to_build.include?(TYPE_GEODE)
      types_to_build = [TYPE_GEODE]
    end

    types_to_build.each do |type_to_build|
      child = BlueprintNode.new(blueprint.robot_cost_schedule, blueprint.available_robots.dup, blueprint.available_resources.dup)
      child.bump_resources
      child.push_robot(type_to_build)
      # What is potential geode count?
      max_geodes_no_build = child.get_geode_robot_count * ([minutes_left - 1, 0].max) + blueprint.get_geode_count
      if max_geodes_no_build >= $max_geode_steps[minutes_left]
        $max_geode_steps[minutes_left] = max_geodes_no_build
        dfs(schedule, child, minutes_left - 1)
      end
    end
  end
end

qualities = []
MASTER_BLUEPRINTS.each_with_index do |master_blueprint, blueprint_index|

  $max_geode_steps = Hash.new { 0 }
  pp 'Building schedule...'
  schedule = BlueprintSchedule.new(master_blueprint)
  pp 'Done.'

  dfs(schedule, master_blueprint, MINUTES, true)
  pp $max_geode_steps[0]

  qualities.push((blueprint_index + 1) * $max_geode_steps[0])
end

pp '##'
pp qualities.reduce(&:+)
