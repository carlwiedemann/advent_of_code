INPUT = File.readlines('./input-day-018.txt')

class SnailFishNumber

  ##
  # @return [Integer]
  #
  attr_accessor :value

  ##
  # @return [SnailFishNumber]
  #
  attr_accessor :left

  ##
  # @return [SnailFishNumber]
  #
  #
  attr_accessor :right

  ##
  # @return [SnailFishNumber]
  #
  attr_accessor :parent

  attr_accessor :arm

  ARM_RIGHT = :arm_right
  ARM_LEFT = :arm_left

  def self.from(v)
    if v.class == SnailFishNumber
      # Already a node.
      instance = v
    elsif v.class == Array
      # An array of potential nodes.
      left_value, right_value = v

      instance = SnailFishNumber.new

      instance.left = SnailFishNumber.from(left_value)
      instance.left.arm = ARM_LEFT
      instance.left.parent = instance

      instance.right = SnailFishNumber.from(right_value)
      instance.right.arm = ARM_RIGHT
      instance.right.parent = instance

      instance.value = nil
    elsif v.class == Integer
      instance = SnailFishNumber.new
      instance.value = v
    else
      raise 'wat'
    end

    instance
  end

  def is_intermediate_dicot?
    !is_base_dicot?
  end

  def is_base_dicot?
    # A node is a base dicot if both left and right are monocots.
    !is_monocot? && (@left.is_monocot? && @right.is_monocot?)
  end

  def is_monocot?
    !@value.nil?
  end

  # @param [SnailFishNumber] tree
  # @param [Array] base nodes
  #
  def self.fetch_base_dicot_nodes(tree, level = 0, base_nodes = [])
    if tree.is_base_dicot?
      base_nodes.push({
                        node: tree,
                        level: level,
                      })
    else
      unless tree.left.is_monocot?
        base_nodes = fetch_base_dicot_nodes(tree.left, level + 1, base_nodes)
      end
      unless tree.right.is_monocot?
        base_nodes = fetch_base_dicot_nodes(tree.right, level + 1, base_nodes)
      end
    end

    base_nodes
  end

  def self.fetch_base_dicot_nodes_min_level(tree, level)
    SnailFishNumber.fetch_base_dicot_nodes(tree).filter do |item|
      item[:level] >= level
    end
  end

  # @param [SnailFishNumber] tree
  def self.fetch_monocot_nodes(tree, monocot_nodes = [])
    if tree.is_monocot?
      monocot_nodes.push(tree)
    else
      monocot_nodes = fetch_monocot_nodes(tree.left, monocot_nodes)
      monocot_nodes = fetch_monocot_nodes(tree.right, monocot_nodes)
    end

    monocot_nodes
  end

  # @return [Array<SnailFishNumber>]
  def self.fetch_monocot_nodes_min_value(tree, value)
    SnailFishNumber.fetch_monocot_nodes(tree).filter do |node|
      node.value >= value
    end
  end

  def get_nearest_left_value
    # We have to bridge over to the left. Therefore, we must enter via a right arm.
    potential_entry = self
    until potential_entry.nil? || potential_entry.arm == ARM_RIGHT
      potential_entry = potential_entry.parent
    end
    # If we never encounter a right arm, let's just return nil.
    if potential_entry.nil?
      nearest_left = nil
    else
      bridge = potential_entry.parent
      potential_outlet = bridge.left

      # The outlet should be a value. We should continue to traverse until it is a value.
      until potential_outlet.is_monocot?
        potential_outlet = potential_outlet.right
      end
      nearest_left = potential_outlet
    end

    nearest_left
  end

  def get_nearest_right_value
    # We have to bridge over to the right. Therefore, we must enter via a left arm.
    potential_entry = self
    until potential_entry.nil? || potential_entry.arm == ARM_LEFT
      potential_entry = potential_entry.parent
    end
    # If we never encounter a right arm, let's just return nil.
    if potential_entry.nil?
      nearest_right = nil
    else
      bridge = potential_entry.parent
      potential_outlet = bridge.right

      # The outlet should be a value. We should continue to traverse until it is a value.
      until potential_outlet.is_monocot?
        potential_outlet = potential_outlet.left
      end
      nearest_right = potential_outlet
    end

    nearest_right
  end

  def convert_to_zero_value
    @left = nil
    @right = nil
    @value = 0
  end

  def convert_to_split_value

    right_add = @value % 2 == 0 ? 0 : 1

    new_left = SnailFishNumber.from(@value / 2)
    new_left.arm = ARM_LEFT
    new_left.parent = self
    @left = new_left

    new_right = SnailFishNumber.from(@value / 2 + right_add)
    new_right.arm = ARM_RIGHT
    new_right.parent = self
    @right = new_right

    @value = nil
  end

  def reduce
    # Reduction always happens at the top level.
    # This means we can traverse down to find levels that match or don't match criteria.
    #
    # - (A) If any pair is nested inside four pairs, the leftmost such pair explodes.
    # - (B) If any regular number is 10 or greater, the leftmost such regular number splits.
    followed_first_rule = false
    followed_second_rule = false

    items_to_explode = SnailFishNumber.fetch_base_dicot_nodes_min_level(self, 4)

    if items_to_explode.count > 0
      followed_first_rule = true

      item = items_to_explode[0]

      # @type [SnailFishNumber]
      node_to_explode = item[:node]

      left_value = node_to_explode.left.value
      right_value = node_to_explode.right.value

      nearest_left_value = node_to_explode.get_nearest_left_value
      if nearest_left_value
        nearest_left_value.value += left_value
        node_to_explode.convert_to_zero_value
      end

      nearest_right_value = node_to_explode.get_nearest_right_value
      if nearest_right_value
        nearest_right_value.value += right_value
        node_to_explode.convert_to_zero_value
      end
    end

    # Only follow second rule if we didn't follow the first rule.

    unless followed_first_rule
      items_to_split = SnailFishNumber.fetch_monocot_nodes_min_value(self, 10)
      if items_to_split.count > 0
        followed_second_rule = true

        node_to_split = items_to_split[0]
        node_to_split.convert_to_split_value
      end
    end

    # Return if we followed either rule.
    followed_first_rule || followed_second_rule
  end

  def plus(b)
    c = SnailFishNumber.from([self, b])
    # Continue to reduce, if feasible.
    loop do
      break unless c.reduce
    end
    c
  end

  def to_a
    if is_monocot?
      @value
    else
      [@left.to_a, @right.to_a]
    end
  end

  def magnitude
    if is_monocot?
      @value
    else
      3 * @left.magnitude + 2 * @right.magnitude
    end
  end

end

# START LOGIC
items = INPUT.map do |line|
  eval(line.strip)
end

# @type [SnailFishNumber]
sum = items.reduce do |memo, input|
  unless memo.class == SnailFishNumber
    memo = SnailFishNumber.from(memo)
  end
  memo.plus(SnailFishNumber.from(input))
end

p sum.to_a
p sum.magnitude



