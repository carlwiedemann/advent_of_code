class Aoc22d20nav
  attr_reader :size

  def initialize(numbers)
    originals = numbers.each_with_index.map do |number, i|
      [i, number]
    end

    @original_items = originals
    @size = originals.count
    @items = originals.dup
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

  def move_item(i)
    item = @original_items[i]
    current_index = get_current_index(item)
    steps = get_item_value(item)
    move_from(item, current_index, steps)
  end

  def move_from(item, current_index, steps)
    # Forward motion less than 1 length
    # steps = 3
    # a b c D e f g h i j
    # a b c e f g D h i j
    #
    # Forward motion crossing 1 length
    # steps = 14
    # a b c D e f g h i j
    # a b c e f g h D i j
    #
    # Forward motion crossing 2 lengths
    # steps = 16
    # a b c D e f g h i j
    # a D b c e f g h i j
    #
    # Backward motion less than 1 length
    # steps = -3
    # a b c d e f G h i j
    # a b c G d e f h i j
    #
    # Forward motion crossing 1 length
    # steps = -14
    # a b c d e f G h i j
    # a G b c d e f h i j
    #
    # Forward motion crossing 2 lengths
    # steps = -16
    # a b c d e f G h i j
    # a b c d e f h i G j

    if steps == 0
      return
    end

    new_index = (current_index + steps) % (@size - 1)

    if new_index == 0
      new_index = @size - 1
    end

    if new_index != current_index
      items_before_current = current_index == 0 ? [] : @items[0..(current_index - 1)]
      items_after_current = current_index == @size - 1 ? [] : @items[(current_index + 1)..]
      if new_index > current_index
        items_in_between = @items[(current_index + 1)..new_index]
      else
        items_in_between = @items[new_index..(current_index - 1)]
      end

      @items = items_before_current + items_after_current

      items_before_new = @items[0..(new_index - 1)]
      items_after_new = new_index == @size - 1 ? [] : @items[new_index..]

      if new_index > current_index
        @items = items_before_current + items_in_between + [item] + items_after_new
      else
        @items = items_before_new + [item] + items_in_between + items_after_current
      end
      @dirty_hash = true
    end
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

  def constrain(index)
    index % @size
  end

  def get_values
    @items.map do |item|
      get_item_value(item)
    end
  end
end