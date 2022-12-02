INPUT = File.readlines('./input-day-025.txt')

grid = INPUT.map do |line|
  line.strip.split(//)
end

class Navigator25

  attr_reader :border

  CUCUMBER_H = '>'
  CUCUMBER_V = 'v'
  EMPTY = '.'

  def initialize(grid)
    @grid = grid
    @x = 0
    @y = 0
    @max_x = grid[0].length - 1
    @max_y = grid.length - 1

    # Define a border that will hold empty coordinates that can
    # receive movement from other pieces.
    # We use a hash for fast access.
    @border = {}
  end

  def key_from(x, y)
    "#{x}_#{y}"
  end

  def coords
    [@x, @y]
  end

  def populate_border
    until eof?
      if is_border?(*coords)
        @border[coords] = coords
      end

      increment
    end
  end

  def do_moves(axis)

    case axis
    when :v
      target = CUCUMBER_V
      get_previous = ->(border_coord) { previous_v_coord(*border_coord) }
      get_next = ->(border_coord) { next_v_coord(*border_coord) }
      filtered_coords = @border.keys.filter { receives_v?(*_1) }
    when :h
      target = CUCUMBER_H
      get_previous = ->(border_coord) { previous_h_coord(*border_coord) }
      get_next = ->(border_coord) { next_h_coord(*border_coord) }
      filtered_coords = @border.keys.filter { receives_h?(*_1) }
    else
      raise 'wat'
    end

    to_add = []
    to_remove = []
    moves = 0

    filtered_coords.each do |border_coord|
      moves += 1
      previous_coord = *get_previous.call(border_coord)
      next_coord = *get_next.call(border_coord)
      # Previous becomes empty
      set_at(*previous_coord, EMPTY)
      # Current becomes target
      set_at(*border_coord, target)
      # Remove current from border
      to_remove.push(border_coord)
      # Add previous to border if it is a border part.
      if is_border?(*previous_coord)
        to_add.push(previous_coord)
      end
      # Add next to border if it is a border part.
      if is_border?(*next_coord)
        to_add.push(next_coord)
      end
    end

    to_add.each { @border[_1] = _1 }
    to_remove.each { @border.delete(_1) }

    moves
  end

  def previous_x(x)
    x == 0 ? @max_x : x - 1
  end

  def previous_y(y)
    y == 0 ? @max_y : y - 1
  end

  def next_x(x)
    x == @max_x ? 0 : x + 1
  end

  def next_y(y)
    y == @max_y ? 0 : y + 1
  end

  def is_border?(x, y)
    is_empty = value_at(x, y) == EMPTY
    receives_h = receives_h?(x, y)
    receives_v = receives_v?(x, y)

    is_empty && (receives_h || receives_v)
  end

  def previous_h_coord(x, y)
    [previous_x(x), y]
  end

  def previous_v_coord(x, y)
    [x, previous_y(y)]
  end

  def next_h_coord(x, y)
    [next_x(x), y]
  end

  def next_v_coord(x, y)
    [x, next_y(y)]
  end

  def receives_h?(x, y)
    value_at(*previous_h_coord(x, y)) == CUCUMBER_H
  end

  def receives_v?(x, y)
    value_at(*previous_v_coord(x, y)) == CUCUMBER_V
  end

  def increment
    @x += 1
    if @x > @max_x
      @x = 0
      @y += 1
    end
  end

  def value_at(x, y)
    @grid[y][x]
  end

  def set_at(x, y, value)
    @grid[y][x] = value
  end

  def current
    value_at(x, y)
  end

  def eof?
    @y == @max_y + 1 && @x == 0
  end

  def to_s
    @grid.map do |row|
      row.join('')
    end.join("\n")
  end

end

nav = Navigator25.new(grid)
nav.populate_border

i = 0

loop do

  h_moves = nav.do_moves(:h)
  v_moves = nav.do_moves(:v)
  i += 1

  if h_moves == 0 && v_moves == 0
    break
  end

end

pp i