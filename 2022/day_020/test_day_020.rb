require 'minitest/autorun'

require_relative 'lib_day_020'

class Aoc22d20navTest < Minitest::Test
  def test_ordering
    n = Aoc22d20nav.new([1, 2, -3, 3, -2, 0, 4])

    assert_equal([1, 2, -3, 3, -2, 0, 4], n.get_values)

    n.move_item(0)
    assert_equal([2, 1, -3, 3, -2, 0, 4], n.get_values)

    n.move_item(1)
    assert_equal([1, -3, 2, 3, -2, 0, 4], n.get_values)

    n.move_item(2)
    assert_equal([1, 2, 3, -2, -3, 0, 4], n.get_values)

    n.move_item(3)
    assert_equal([1, 2, -2, -3, 0, 3, 4], n.get_values)

    n.move_item(4)
    assert_equal([1, 2, -3, 0, 3, 4, -2], n.get_values)

    n.move_item(5)
    assert_equal([1, 2, -3, 0, 3, 4, -2], n.get_values)

    n.move_item(6)
    assert_equal([1, 2, -3, 4, 0, 3, -2], n.get_values)
  end
end
