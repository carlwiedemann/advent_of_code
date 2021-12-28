INPUT = File.readlines('./input-day-016.txt')

value = INPUT[0].strip

def debug_message(nest, message)
  # p ('-' * nest) + message.to_s
end

def hex_to_bin(hex)
  hex.split('').reduce('') do |memo, num|
    memo += sprintf("%b", num.hex).rjust(4, '0')
    memo
  end
end

def bin_to_dec(bin)
  bin.to_i(2)
end

def extract_raw_header(hex)
  hex_to_bin(hex)[0..5]
end

def rest_of_string(string, index)
  string[Range.new(index, string.length - 1)]
end

TYPE_DIGIT_LITERAL = 4
TYPE_LITERAL = 'literal'
TYPE_OPERATOR = 'operator'
TYPE_NULL = 'null'

LENGTH_TYPE_BITS = 0
LENGTH_TYPE_QUANTITY = 1

def sum_of_bits(children)
  sum = 0
  queue = children.dup
  while queue.count > 0
    item = queue.shift
    if item[:bits_used].nil?
      item[:children].each { |child| queue.push(child) }
    else
      sum += item[:bits_used]
    end
  end

  sum
end

def parse(as_bin, allowed = nil, nest = 0)
  if as_bin.to_i(2) == 0
    return [
      {
        version: 0,
        type: TYPE_NULL,
        type_digit: -1,
        bits_used: as_bin.length,
        value: 0,
        children: [],
      }
    ]
  end

  if allowed == 0
    return []
  elsif allowed.nil?
    next_allowed = nil
  else
    next_allowed = allowed - 1
  end

  raw_header = as_bin[0..5]
  remainder = rest_of_string(as_bin, 6)

  version = bin_to_dec(raw_header[0..2])
  type_digit = bin_to_dec(raw_header[3..5])

  type = (type_digit == TYPE_DIGIT_LITERAL) ? TYPE_LITERAL : TYPE_OPERATOR

  if type == TYPE_LITERAL
    debug_message(nest, 'literal')
    children = []

    parts = ''
    cursor = 0
    finished = false
    while cursor < remainder.length && !finished
      # Look at 5 at a time.
      chunk = remainder[Range.new(cursor, cursor + 5 - 1)]
      parts += rest_of_string(chunk, 1)
      if (chunk[0]).to_i == 0
        finished = true
      end
      cursor += 5
    end
    value = parts.to_i(2)

    initial = {
      version: version,
      type: type,
      type_digit: type_digit,
      bits_used: cursor + 6,
      value: value,
      children: children,
    }

    leftover_bits = rest_of_string(remainder, cursor)
  else
    length_type_id = remainder[0].to_i

    if length_type_id == LENGTH_TYPE_BITS
      debug_message(nest, 'length_type_bits')

      number_of_bits = remainder[1..15].to_i(2)
      cursor = 16
      end_of_children = cursor + number_of_bits - 1

      children_bits = remainder[Range.new(cursor, end_of_children)]

      children = parse(children_bits, nil, nest + 1)
      # We know there are additional if the children bits do not take up the rest of the remainder.
      children_bits_used = children_bits.length

      debug_message(nest, 'children_bits_used (from length_type_bits)')
      debug_message(nest, children_bits_used)

      bits_used = cursor + 6 + children_bits_used

      debug_message(nest, 'bits_used')
      debug_message(nest, bits_used)

      leftover_bits = rest_of_string(remainder, end_of_children + 1)

    elsif length_type_id == LENGTH_TYPE_QUANTITY
      debug_message(nest, 'length_type_quantity')
      number_of_packets = remainder[1..11].to_i(2)
      cursor = 12
      children_bits = rest_of_string(remainder, cursor)

      children = parse(children_bits, number_of_packets, nest + 1)
      # We know there are additional if bits that the children used do not equal the total children bits.
      # bits_used = cursor + sum_of_bits(children)
      children_bits_used = sum_of_bits(children)
      end_of_children = cursor + children_bits_used - 1
      bits_used = cursor + 6 + children_bits_used

      debug_message(nest, 'children_bits_used (from length_type_quantity)')
      debug_message(nest, children_bits_used)

      debug_message(nest, 'bits_used')
      debug_message(nest, bits_used)

      leftover_bits = rest_of_string(remainder, end_of_children + 1)
    else
      raise 'wat'
    end


    # Use the actual type_digit
    case type_digit
    when 0
      # Sum
      value = children.reduce(0) do |memo, child|
        memo += child[:value]
        memo
      end
    when 1
      # Product
      value = children.reduce(1) do |memo, child|
        memo *= child[:value]
        memo
      end
    when 2
      # Min
      value = children.reduce(children.first[:value]) do |memo, child|
        if child[:value] < memo
          memo = child[:value]
        end
        memo
      end
    when 3
      # Max
      value = children.reduce(children.first[:value]) do |memo, child|
        if child[:value] > memo
          memo = child[:value]
        end
        memo
      end
    when 5
      # Greater than
      value = children[0][:value] > children[1][:value] ? 1 : 0
    when 6
      # Less than
      value = children[0][:value] < children[1][:value] ? 1 : 0
    when 7
      # Equal to
      value = children[0][:value] == children[1][:value] ? 1 : 0
    else
      raise 'wat'
    end

    initial = {
      version: version,
      type: type,
      type_digit: type_digit,
      bits_used: bits_used,
      value: value,
      children: children,
    }

  end

  debug_message(nest, 'leftover_bits')
  debug_message(nest, leftover_bits)
  if leftover_bits.length > 0
    additional = parse(leftover_bits, next_allowed, nest)
  else
    additional = []
  end

  [initial] + additional
end

as_bin = hex_to_bin(value)
# p as_bin

tree = parse(as_bin)[0]
# pp tree

# Part 1.
queue = []
queue.push(tree)
version_sum = 0
while queue.count > 0
  node = queue.shift
  version_sum += node[:version]
  node[:children].each { |child| queue.push(child) }
end

p version_sum

# Part 2
p tree[:value]
