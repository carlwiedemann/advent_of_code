INPUT = File.readlines('./input_day_011.txt')

map = INPUT.map do |line|
  line.strip.split('').map(&:to_i)
end

STEPS = 1000

class NavigatorEleven

  def initialize(map)
    @map = map
    @x_index = 0
    @y_index = 0
    @x_length = map[0].length
    @x_max = @x_length - 1
    @y_length = map.length
    @y_max = @y_length - 1
  end

  def reset(x = 0, y = 0)
    @x_index = x
    @y_index = y
  end

  def size
    @x_length * @y_length
  end

  def goto(x, y)
    reset(x, y)
  end

  def get_position
    [@x_index, @y_index]
  end

  def incrementable_surroundings
    base = [
      northwest, north, northeast,
      west, east,
      southwest, south, southeast,
    ]

    valid_base = base.compact

    valid_base.select do |coord|
      get_value(*coord) < 10
    end
  end

  def next
    not_finished = true

    @x_index += 1
    if @x_index > @x_max
      @y_index += 1
      @x_index = 0
      if @y_index > @y_max
        not_finished = false
      end
    end

    not_finished
  end

  def get_current_value
    get_value(@x_index, @y_index)
  end

  def get_current_coords
    [
      @x_index,
      @y_index
    ]
  end

  def set_current_value(value)
    set_value(@x_index, @y_index, value)
  end

  def get_value(x, y)
    @map[y][x]
  end

  def set_value(x, y, value)
    @map[y][x] = value
  end

  def coord_or_nil(coord)
    x = coord[0]
    y = coord[1]
    x_in_range = x >= 0 && x < @x_length
    y_in_range = y >= 0 && y < @y_length

    x_in_range && y_in_range ? coord : nil
  end

  def northwest
    coord_or_nil([@x_index - 1, @y_index - 1])
  end

  def north
    coord_or_nil([@x_index, @y_index - 1])
  end

  def northeast
    coord_or_nil([@x_index + 1, @y_index - 1])
  end

  def west
    coord_or_nil([@x_index - 1, @y_index])
  end

  def east
    coord_or_nil([@x_index + 1, @y_index])
  end

  def southwest
    coord_or_nil([@x_index - 1, @y_index + 1])
  end

  def south
    coord_or_nil([@x_index, @y_index + 1])
  end

  def southeast
    coord_or_nil([@x_index + 1, @y_index + 1])
  end

  def increment
    set_current_value(get_current_value + 1)

    flashing
  end

  def flashing
    get_current_value == 10 ? get_current_coords : nil
  end

  def get_map
    @map.map do |row|
      row.join('')
    end.join("\n")
  end

end

nav = NavigatorEleven.new(map)

flash_count = 0
final_flash_count = 0
flash_step = nil

STEPS.times do |step|

  flash_queue = []
  reset_queue = []

  nav.reset

  loop do
    flashing = nav.increment
    if flashing
      flash_count += 1
      incrementable_surroundings = nav.incrementable_surroundings
      flash_queue += incrementable_surroundings
      reset_queue.push(flashing)
    end

    break unless nav.next
  end

  while flash_queue.length > 0
    position = flash_queue.shift
    nav.goto(*position)
    flashing = nav.increment
    if flashing
      flash_count += 1
      flash_queue += nav.incrementable_surroundings
      reset_queue.push(flashing)
    end
  end

  if step == 99
    final_flash_count = flash_count
  end

  if reset_queue.length == nav.size && flash_step.nil?
    flash_step = step
  end

  while reset_queue.length > 0
    position = reset_queue.shift
    nav.goto(*position)
    nav.set_current_value(0)
  end

end

p final_flash_count
p flash_step + 1
