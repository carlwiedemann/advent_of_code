INPUT = File.readlines("#{File.dirname(__FILE__)}/input_day_025.txt")
lines = INPUT.map(&:strip)

def dec_2_snafu(number)
  str = ''
  loop do
    break if number == 0
    quo = number / 5
    rem = number % 5
    case rem
    when 3
      sub = '='
      carry = 1
    when 4
      sub = '-'
      carry = 1
    else
      sub = rem.to_s
      carry = 0
    end
    str = sub + str
    number = quo + carry
  end

  if str == ''
    str = '0'
  end

  str
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