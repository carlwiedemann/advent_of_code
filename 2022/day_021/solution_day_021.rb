INPUT = File.readlines("#{File.dirname(__FILE__)}/input_day_021.txt")
lines = INPUT.map(&:strip)

DICT = {}

class Node
  attr_accessor :name, :name_left, :name_right, :op
  attr_writer :result

  def result
    return @result unless @result.nil?

    left = DICT[@name_left].result
    right = DICT[@name_right].result

    @result = eval("#{left} #{@op} #{right}")
  end
end

lines.each do |line|
  parts = line.split(':').map(&:strip)

  n = Node.new
  n.name = parts[0]

  second_parts = parts[1].split
  if second_parts.count == 3
    n.name_left = second_parts[0]
    n.op = second_parts[1]
    n.name_right = second_parts[2]
  else
    n.result = second_parts[0].to_i
  end

  DICT[n.name] = n
end

# Part 1.
# pp DICT['root'].result

# Part 2.
# Which branch has 'humn'?
MONKEY_ME = 'humn'
# @param [Node] node
def find_monkey(node, name)
  if node.name == name
    node
  else
    potential = nil
    if node.name_left
      potential = find_monkey(DICT[node.name_left], name)
      if potential.nil? && node.name_right
        potential = find_monkey(DICT[node.name_right], name)
      end
    end
    potential
  end
end

# Which branch has me?

# @return [[Node, Node, Symbol], nil]
def branches_for_me(node)
  if node.name_left.nil?
    nil
  else
    left = DICT[node.name_left]
    right = DICT[node.name_right]
    node_me = find_monkey(left, MONKEY_ME)
    if node_me
      node_mine = left
      node_other = right
      side = :left
    else
      node_mine = right
      node_other = left
      side = :right
    end

    [node_mine, node_other, side]
  end
end

my_root_branches = branches_for_me(DICT['root'])

result = my_root_branches[1].result
pp result
pp 'me'
me_rn = my_root_branches[0].result
pp me_rn

trio = branches_for_me(my_root_branches[0])
op = my_root_branches[0].op
loop do

  raise 'wat' if trio.nil?

  (node, other_node, side_mine) = trio

  # Which side of the op are we concerned with?
  on_left = side_mine == :left

  case op
  when '+'
    result = result - other_node.result
  when '-'
    if on_left
      result = result + other_node.result
    else
      result = other_node.result - result
    end
  when '*'
    result = result / other_node.result
  when '/'
    if on_left
      result = result * other_node.result
    else
      result = other_node.result / result
    end
  end

  break if node.name == MONKEY_ME
  op = node.op
  trio = branches_for_me(node)
end

pp result

