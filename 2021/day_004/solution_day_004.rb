INPUT = File.readlines('./input_day_004.txt')
lines = INPUT.map(&:strip)

plays = lines.shift.to_s.split(',').map(&:to_i)

class Board

  def initialize
    @rows = []
    @plays = []
  end

  def push_row(row)
    @rows.push(row)
  end

  def make_play(play)
    @plays.push(play)
  end

  def winning?
    rows_have_bingo || cols_have_bingo
  end

  def rows_have_bingo()
    @rows.reduce(false) do |memo, row|
      memo ||= Board.array_has_bingo(row, @plays)
      memo
    end
  end

  def cols_have_bingo
    cols = @rows.transpose
    cols.reduce(false) do |memo, col|
      memo ||= Board.array_has_bingo(col, @plays)
      memo
    end
  end

  def self.array_has_bingo(arr, plays)
    arr & plays == arr
  end

  def sum_unplayed
    (@rows.flatten - @plays).reduce(&:+) || @rows.flatten.reduce(&:+)
  end

end

last_line_valid = false

# @type [Array<Board>]
boards = lines.reduce([]) do |memo, line|
  current_line_valid = line.length > 0

  if current_line_valid && !last_line_valid
    board = Board.new
    memo.push(board)
    board.push_row(line.split.map(&:to_i))
  elsif current_line_valid && last_line_valid
    board = memo.last
    board.push_row(line.split.map(&:to_i))
  end

  last_line_valid = current_line_valid

  memo
end

winning_boards = plays.reduce({}) do |memo, play|
  boards.map.with_index do |board, i|
    board.make_play(play)
    if board.winning? && !memo[i]
      memo[i] = board.sum_unplayed * play
    end
  end

  memo
end

# Part 1
p winning_boards[winning_boards.keys.first]

# Part 2
p winning_boards[winning_boards.keys.last]
