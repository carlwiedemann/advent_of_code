INPUT = File.readlines('./input_day_017.txt')
bounds = INPUT[0].strip.split(':')[1].strip.split(', ').map do |bounds_str|
  bounds_str.split('=')[1].split('..').map(&:to_i)
end

X_BOUNDS = bounds[0]
Y_BOUNDS = bounds[1]

X_MIN = X_BOUNDS.min
X_MAX = X_BOUNDS.max

Y_MIN = Y_BOUNDS.min
Y_MAX = Y_BOUNDS.max

def x_position_at(xv_i, n)
  n.times.reduce(0) do |memo, i|
    potential = xv_i - i
    memo += potential < 0 ? 0 : potential

    memo
  end
end

def y_position_at(yv_i, n)
  yv_i * n - n * (n - 1)/2
end

def xp_in_target(xp)
  xp >= X_MIN && xp <= X_MAX
end

def yp_in_target(yp)
  yp >= Y_MIN && yp <= Y_MAX
end

def position_at(xv_i, yv_i, n)
  [
    x_position_at(xv_i, n),
    y_position_at(yv_i, n),
  ]
end

def xp_overshot(xp)
  xp > X_MAX
end

def yp_overshot(yp)
  yp < Y_MIN
end

def yp_undershot(yp)
  yp > Y_MAX
end

def position_overshot(position)
  xp_overshot(position[0]) || yp_overshot(position[1])
end

def position_in_target(position)
  xp_in_target(position[0]) && yp_in_target(position[1])
end

# This exercise is about optimizing the problem space.

# For a given X velocity, we can find the step numbers that are valid which will give us some range to explore.

# x lower = 1
# x upper = X_BOUNDS.max, because at the first step this will overshoot the bounds.

# each good result will provide some [xv, xp, n]

position_seeds = []

1.upto(X_MAX) do |xv_i|
  n = 0
  while n <= X_MAX do
    # Keep only the first one.
    x_position = x_position_at(xv_i, n)
    next_x_position = x_position_at(xv_i, n + 1)
    x_terminal = x_position == next_x_position
    if xp_in_target(x_position)
      position_seeds.push({
                            xv_i: xv_i,
                            n: n,
                            x_position: x_position,
                            x_terminal: x_terminal
                          })
    end
    # If we have already overshot or we are terminal, just break.
    if xp_overshot(x_position) || x_terminal
      break
    end
    n += 1
  end
end

# yp_n = yv_i + (yv_i - 1) + (yv_i - 2) + (yv_i - 3) = n * yv_i - n*(n - 1) / 2
#      = n * (yv_i - n/2 + 1/2)
# 0 = n * (yv_i - n/2 + 1/2)
# 0 = yv_i - n/2 + 1/2

# The necessary y velocity in terms of the iteration, if that iteration is zero.
# yv_i = (n - 1)/2

# Given a certain velocity, the iteration at which it will be zero.
# n = 2*yv_i + 1
# A similar formula should exist for the peak. @todo

# For yv_i > 0, we can calculate the iteration at which it will be zero
# n = 2*yv_i + 1
# We can then subsequently calculate the very next position, which will be a negative number, increasing toward negative
# infinity.
# We repeat this calculation until the y position is overshot. The last valid position will be our yv_i.

position_overshot = false
yv_i = 1
highest_n = nil
highest_yv_i = nil

until position_overshot
  n = 2 * yv_i + 1
  # Get next position
  yp_after_zero = y_position_at(yv_i, n + 1)
  position_overshot = yp_overshot(yp_after_zero)
  unless position_overshot
    highest_yv_i = yv_i
    highest_n = n
    yv_i += 1
  end
end

# Part 1
# @type [Integer]
max_height = y_position_at(highest_yv_i, (highest_n - 1) / 2)

# p 'n'
# p highest_n
# p 'yv_i'
# p highest_yv_i
# p 'height'
p max_height

# @type [Integer]
min_height = Y_MIN

# Given `hightest_yv_i`, we know the domain for the y values, which means that we can traverse this domain to understand
# which y values produce target hits.

# For non-x_terminal position seeds, we'll want scan all y values at the given n, then record what hits.
non_terminal_position_seeds = position_seeds.reject { |position_seed| position_seed[:x_terminal] }

# For x_terminal position seeds, we'll want to scan all y values starting at the n provided, then going until the
# `highest_n` value.
terminal_position_seeds = position_seeds.filter { |position_seed| position_seed[:x_terminal] }

# Non-terminal first.
valid_trajectories = []

valid_trajectories = non_terminal_position_seeds.reduce(valid_trajectories) do |memo, position_seed|

  # Record what hits.
  min_height.upto(max_height) do |nt_yv_i|
    nt_n = position_seed[:n]
    if position_in_target(position_at(position_seed[:xv_i], nt_yv_i, nt_n))
      memo.push([position_seed[:xv_i], nt_yv_i])
    end
  end

  memo
end

p valid_trajectories.uniq.count

# @type [Integer]
t_n_f = highest_n + 1

# Then, terminal.
valid_trajectories = terminal_position_seeds.reduce(valid_trajectories) do |memo, position_seed|

  # @type [Integer]
  t_n_i = position_seed[:n]

  t_n_i.upto(t_n_f) do |n|
    # Record what hits.
    min_height.upto(max_height) do |t_yv_i|
      if yp_in_target(y_position_at(t_yv_i, n))
        memo.push([position_seed[:xv_i], t_yv_i])
      end
    end
  end

  memo
end

p valid_trajectories.uniq.count

# p terminal_position_seeds



