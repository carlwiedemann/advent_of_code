# @type [Array]
raw_input = File.readlines('./input-day-03.txt')
input = raw_input.map { |line| line.strip }

def get_digit_count(numbers)
  numbers[0].strip.length
end

def get_most_common_digits(strings)
  lines = strings.count
  digit_count = get_digit_count(strings)

  sums = strings.reduce(Array.new(digit_count, 0)) do |memo, line|
    positions = line.split('')
    positions.each_with_index.map do |digit, i|
      memo[i] += digit.to_i
    end
    memo
  end

  sums.map do |sum|
    (sum < (lines.to_f / 2)) ? 0 : 1
  end
end

def get_least_common_digits(strings)
  get_most_common_digits(strings).map { |i| i ^ 1 }
end

most_common_digits = get_most_common_digits(input)
digit_count = get_digit_count(input)

g = (most_common_digits.join).to_i(2)

e = ((2 ** digit_count) - 1) ^ g

# Part 1
p g * e

least_common_digits = get_least_common_digits(input)

def filter_from_common(input, common_digits, recalc)
  digit_count = get_digit_count(input)

  j = 0
  while j < common_digits.length
    digit = common_digits[j]
    selector = 2 ** (digit_count - 1 - j)
    check = digit * selector

    i = 0
    while i < input.length && input.length > 1
      input_digit = input[i].to_i(2) & selector
      if input_digit ^ check > 0
        input[i] = nil
      end
      i += 1
    end

    input.compact!
    common_digits = recalc.call(input)
    j += 1
  end

  input[0].to_i(2)
end

input1 = input.dup
input2 = input.dup

a = filter_from_common(input1, most_common_digits, ->(input) {get_most_common_digits(input)})

b = filter_from_common(input2, least_common_digits, ->(input) {get_least_common_digits(input)})

p a * b