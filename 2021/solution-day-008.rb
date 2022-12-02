INPUT = File.readlines('./input-day-008.txt')
all_output_items = INPUT.map(&:strip).map { _1.split('|')[1].strip.split }
all_input_items = INPUT.map(&:strip).map { _1.split('|')[0].strip.split }
all_items = INPUT.map(&:strip).map { _1.split('|').join.split.map(&:strip) }

EASY_DIGIT_SEGMENT_MAP = {
  one: 2,
  four: 4,
  seven: 3,
  eight: 7
}

HARD_DIGIT_SEGMENT_MAP = {
  zero: 6, # one - r4, seven - r3, *four - r4*, eight - r1
  two: 5, # one - r5, seven - r4, *four - r5*, eight - r2
  three: 5, # one - r3, *seven - r2*, four - r3, eight - r2
  five: 5, # one - r5, seven - r4, *four - r3*, eight - r2
  six: 6, # one - r6, *seven - r5*, four - r4, eight - r1
  nine: 6 # one - r4, seven - r3, *four - r2*, eight - r1
}

def pattern_diff(a, b)
  if b
    a_split = a.split('')
    b_split = b.split('')
    (a_split - b_split | b_split - a_split).length
  end
end

def convert(candidate, knowns = [])

  case candidate.length
  when 2 then value = 1
  when 4 then value = 4
  when 3 then value = 7
  when 7 then value = 8
  else
    value = -1
  end

  if value == -1
    if knowns.length > 0
      # If length isn't known, we have to consult the knowns.
      one_pattern = knowns.find { convert(_1) == 1 }
      four_pattern = knowns.find { convert(_1) == 4 }
      seven_pattern = knowns.find { convert(_1) == 7 }
      eight_pattern = knowns.find { convert(_1) == 8 }

      if candidate.length == 5
        # Either 2, 3, or 5
        if pattern_diff(candidate, seven_pattern) == 2
          value = 3
        elsif pattern_diff(candidate, four_pattern) == 5
          value = 2
        elsif pattern_diff(candidate, four_pattern) == 3
          value = 5
        else
          value = -1
        end
      elsif candidate.length == 6
        # Either 0, 6, or 9
        if pattern_diff(candidate, seven_pattern) == 5
          value = 6
        elsif pattern_diff(candidate, four_pattern) == 4
          value = 0
        elsif pattern_diff(candidate, four_pattern) == 2
          value = 9
        else
          value = -1
        end
      else
        raise 'wat' + candidate
      end
    else
      value = -1
    end
  end

  value
end

HARD_DIGIT_SEGMENT_COUNTS = HARD_DIGIT_SEGMENT_MAP.values

count = all_output_items.reduce(0) do |memo, output_items|
  memo += (output_items.map(&:length) - HARD_DIGIT_SEGMENT_COUNTS).length
  memo
end

# Part 1
p count

result = all_items.map do |full_list|
  potential_items = full_list.map do |candidate|
    value = convert(candidate, full_list)
    (value > 0) ? value : candidate
  end

  # Some of these still have letters.
  revised_potential_items = potential_items.reduce([]) do |memo, potential_item|
    if potential_item.is_a?(String)
      if potential_item.length == 5
        if potential_items.include?(2) && potential_items.include?(3)
          new_potential_item = 5
        elsif potential_items.include?(2) && potential_items.include?(5)
          new_potential_item = 3
        elsif potential_items.include?(3) && potential_items.include?(5)
          new_potential_item = 2
        else
          # :(
          new_potential_item = potential_item
        end
      else
        if potential_items.include?(6) && potential_items.include?(9)
          new_potential_item = 0
        elsif potential_items.include?(0) && potential_items.include?(9)
          new_potential_item = 6
        elsif potential_items.include?(0) && potential_items.include?(6)
          new_potential_item = 9
        else
          # :(
          new_potential_item = potential_item
        end
      end

    else
      new_potential_item = potential_item
    end

    memo.push(new_potential_item)

    memo
  end

  revised_potential_items.last(4).join.to_i
end

# Part 2
p result.reduce(&:+)
