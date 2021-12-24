INPUT = File.readlines('./input-day-017.txt')
bounds = INPUT[0].strip.split(':')[1].strip.split(', ').map do |bounds_str|
  bounds_str.split('=')[1].split('..').map(&:to_i)
end

X_BOUNDS = bounds[0]
Y_BOUNDS = bounds[1]

def x_position_at(xv_i, n)
  n.times.reduce(0) do |memo, i|
    memo += [0, xv_i - i].max

    memo
  end
end

def y_position_at(yv_i, n)
  n.times.reduce(0) do |memo, i|
    memo += yv_i - i

    memo
  end
end

def xp_in_target(xp)
  xp >= X_BOUNDS.min && xp <= X_BOUNDS.max
end

def yp_in_target(yp)
  yp >= Y_BOUNDS.min && yp <= Y_BOUNDS.max
end

def position_at(xv_i, yv_i, n)
  [
    x_position_at(xv_i, n),
    y_position_at(yv_i, n),
  ]
end

def xp_overshot(xp)
  xp > X_BOUNDS.max
end

def yp_overshot(yp)
  yp < Y_BOUNDS.min
end

def yp_undershot(yp)
  yp > Y_BOUNDS.max
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

1.upto(X_BOUNDS.max) do |xv_i|
  n = 0
  while n <= X_BOUNDS.max do
    # Keep only the first one.
    x_position = x_position_at(xv_i, n)
    next_x_position = x_position_at(xv_i, n + 1)
    x_terminal = x_position == next_x_position
    if xp_in_target(x_position) && x_terminal
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

p position_seeds



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



