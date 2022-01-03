


class ImageTwenty

  attr_reader :algorithm_tree
  attr_reader :iteration

  def initialize(algorithm_pieces, image_pieces)
    initialize_algorithm(algorithm_pieces)
    initialize_image(image_pieces)
    @iteration = 0
  end

  DIGIT_SIZE = 9

  # @param [Array<Integer>] algorithm_pieces
  def initialize_algorithm(algorithm_pieces)
    @algorithm_tree = Array.new(2)
    algorithm_pieces.each_with_index do |value, index|
      # Convert into 9-digit binary number as an array.
      digits = index.to_s(2).rjust(DIGIT_SIZE, 0.to_s).split(//).map(&:to_i)
      tree_digits = digits.first(DIGIT_SIZE - 1)
      final_digit = digits.last
      final_tree = tree_digits.reduce(@algorithm_tree) do |memo, digit|
        memo[digit] = Array.new(2) if memo[digit].nil?

        memo[digit]
      end
      final_tree[final_digit] = value
    end

    @algorithm_tree
  end

  def initialize_image(image_pieces)
    @image = image_pieces
    # Initialize.
    @light_colored_squares = count_grid(@image)
  end

  def count_grid(grid)
    grid.reduce(0) do |memo, row|
      row.reduce(memo) do |memo2, value|
        memo2 += value

        memo2
      end
    end
  end

  def get_next_value_from_grid(a, b, c, d, e, f, g, h, i)
    @algorithm_tree[a][b][c][d][e][f][g][h][i]
  end

  def get_max_index
    @max_index = @image.length - 1
  end

  def default_for_next(iteration)
    if iteration % 2 == 0
      @_even_default ||= get_next_value_from_grid(0, 0, 0, 0, 0, 0, 0, 0, 0)
    else
      @_odd_default ||= get_next_value_from_grid(1, 1, 1, 1, 1, 1, 1, 1, 1)
    end
  end

  def existing_value_at(x, y, iteration)
    if x < 0 || x > @max_index || y < 0 || y > @max_index
      default_for_next(iteration)
    else
      @image[y][x]
    end
  end

  def next_value_at(x, y, iteration)
    old_x = x - 1
    old_y = y - 1

    left_x = old_x - 1
    middle_x = old_x
    right_x = old_x + 1

    top_y = old_y - 1
    middle_y = old_y
    bottom_y = old_y + 1

    a = existing_value_at(left_x, top_y, iteration)
    b = existing_value_at(middle_x, top_y, iteration)
    c = existing_value_at(right_x, top_y, iteration)

    d = existing_value_at(left_x, middle_y, iteration)
    e = existing_value_at(middle_x, middle_y, iteration)
    f = existing_value_at(right_x, middle_y, iteration)

    g = existing_value_at(left_x, bottom_y, iteration)
    h = existing_value_at(middle_x, bottom_y, iteration)
    i = existing_value_at(right_x, bottom_y, iteration)

    get_next_value_from_grid(a, b, c, d, e, f, g, h, i)
  end

  def enhance
    # We are going to create a new image. The new image will be (n + 2) x (n + 2)
    new_max = get_max_index + 2

    new_image = Array.new(new_max)

    @light_colored_squares = 0

    new_max.times do |new_y|
      new_max.times do |new_x|
        # Initialize if necessary.
        new_image[new_y] ||= Array.new(new_max)
        next_value = next_value_at(new_x, new_y, @iteration)
        @light_colored_squares += next_value
        new_image[new_y][new_x] = next_value
      end
    end

    @image = new_image

    @iteration += 1

  end

end