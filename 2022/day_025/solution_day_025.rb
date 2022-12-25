INPUT = File.readlines("#{File.dirname(__FILE__)}/input_day_025.txt")
lines = INPUT.map(&:strip)

def dec_2_snafu(number)
  snafu_string = ''

  loop do
    break if number == 0

    quotient = number / 5
    remainder = number % 5

    case remainder
    when 3
      sub = '='
      carry = 1
    when 4
      sub = '-'
      carry = 1
    else
      sub = remainder.to_s
      carry = 0
    end

    snafu_string = "#{sub.to_s}#{snafu_string}"
    number = quotient + carry
  end

  if snafu_string == ''
    snafu_string = '0'
  end

  snafu_string
end

def snafu_2_dec(snafu)
  length = snafu.length

  length.times.reduce(0) do |memo, i|
    char = snafu[length - 1 - i]

    case char
    when '-'
      factor = -1
    when '='
      factor = -2
    else
      factor = char.to_i
    end

    memo + (5 ** i) * factor
  end
end

pp dec_2_snafu(lines.reduce(0) { |memo, line| memo + snafu_2_dec(line) })