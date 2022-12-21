INPUT = File.readlines("#{File.dirname(__FILE__)}/input_day_020.txt")
numbers = INPUT.map(&:strip).map(&:to_i)

originals = numbers.each_with_index.map do |number, i|
  [i, number]
end

class D20nav
  def initialize(old_items)
    @size = old_items.count
    @items = old_items.dup
    @index_hash = {}
    @dirty_hash = true
  end

  def get_current_index(item)
    recalc_index_hash
    @index_hash[item]
  end

  def get_item_value(item)
    item.last
  end

  def move_item(item)
    # Get current index.
    current_index = get_current_index(item)
    # Calculate next index.
    item_value = get_item_value(item)
    raw_index_next = current_index + item_value
    next_index = raw_index_next
    # Insert item at next index.
    move_from(item, current_index, next_index, item_value > 0 ? 1 : -1)
  end

  def move_from(item, a, b, dir)
    if constrain(a) == 0 && constrain(b) == 0 && dir < 0
      @items.shift
      @items.push(item)
      @dirty_hash = true
    elsif a != b
      next_index = a + dir
      if constrain(next_index) == @size - 1 && dir < 0
        @items.shift
        @items.push(item)
        @dirty_hash = true
        tmp = read_item_at(next_index - 1)
        write_item_at(next_index - 1, item)
        write_item_at(next_index, tmp)
        move_from(item, next_index - 1, b - 1, dir)
      elsif constrain(next_index) == 0 && dir > 0
        @items.pop
        @items.unshift(item)
        @dirty_hash = true
        tmp = read_item_at(next_index + 1)
        write_item_at(next_index + 1, item)
        write_item_at(next_index, tmp)
        move_from(item, next_index + 1, b + 1, dir)
      else
        tmp = read_item_at(next_index)
        write_item_at(next_index, item)
        write_item_at(a, tmp)
        if dir < 0 && constrain(next_index) == 0
          @items.shift
          @items.push(item)
          @dirty_hash = true
          move_from(item, next_index - 1, b - 1, dir)
        else
          move_from(item, next_index, b, dir)
        end
      end
    end
  end

  def write_item_at(index, item)
    constrained_index = constrain(index)
    @items[constrained_index] = item
    @dirty_hash = true
  end

  def recalc_index_hash
    if @dirty_hash
      @index_hash = {}
      @items.each_with_index do |item, i|
        @index_hash[item] = i
      end
      @dirty_hash = false
    end
  end

  def read_item_at(index)
    @items[constrain(index)]
  end

  def constrain(index)
    index % @size
  end

  def get_values
    @items.map do |item|
      get_item_value(item)
    end
  end
end

nav = D20nav.new(originals)

originals.each_with_index do |original, i|
  nav.move_item(original)
end

values = nav.get_values
zero_index = values.index(0)
sum = [1000, 2000, 3000].reduce(0) do |memo, i|
  memo + values[nav.constrain(zero_index + i)]
end

pp sum








