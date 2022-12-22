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
pp DICT['root'].result

# Part 2.
# Which branch has 'humn'?
# @param [Node] node
def find_monkey(node, name)
  if node.name == name

  end
  left_node = DICT[node.name_left]
  right_node = DICT[node.name_right]
end
