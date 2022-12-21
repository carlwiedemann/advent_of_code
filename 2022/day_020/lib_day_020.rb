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