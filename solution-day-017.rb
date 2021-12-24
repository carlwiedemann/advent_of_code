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

# For a given X velocity, we can find the step numbers that are valid
# which will give us some range to explore.
# x lower = 1
# x upper = X_BOUNDS.max
# each good result will provide some [x, n]

position_seeds = []

1.upto(X_BOUNDS.max) do |xv|
  n = 0
  while n <= X_BOUNDS.max do
    # Keep only the first one.
    x_position = x_position_at(xv, n)
    next_x_position = x_position_at(xv, n + 1)
    x_terminal = x_position == next_x_position
    if xp_in_target(x_position)
      position_seeds.push({
                            xv: xv,
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

valid_velocities = []

# For these step numbers, we should try various y > 0 values, until all positions are above
# the top of the y boundary.
position_seeds.map do |position_seed|
  yv = 1
  exhausted_y = false
  until exhausted_y
    n = position_seed[:n]
    y_position = y_position_at(yv, n)

    if yp_in_target(y_position)
      # p 'position'
      # p [position_seed[:x_position], y_position]
      # p 'velocity'
      # p [position_seed[:xv], yv, n]
      # p 'check'
      # p position_at(position_seed[:xv], yv, n)
      # p '--'
      valid_velocities.push({
                              xv: position_seed[:xv],
                              yv: yv,
                              n: n
                            })
    end

    # Take into account terminal velocities.
    if position_seed[:x_terminal]
      # If we are terminal, we should explore further iterations, until we are overshot.
      until yp_overshot(y_position)
        y_position = y_position_at(yv, n)
        if yp_in_target(y_position)
          valid_velocities.push({
                                  xv: position_seed[:xv],
                                  yv: yv,
                                  n: n
                                })
        end
        n += 1
      end
      # Have we exhausted all Y's? Not really, we might be able to increase the Y and increase the count and also hit
      exhausted_y = true
    else
      # If the velocity isn't terminal, we will know when we have exhausted
      # the y position
      exhausted_y = yp_undershot(y_position)
    end

    yv += 1
  end

end

p valid_velocities
# p position_at(6, 9, 20)
# p position_at(6, 10, 21)
# p position_at(6, 10, 22)
p position_at(6, 11, 23)
p position_at(6, 11, 24)

p position_at(6, 12, 25)
p position_at(6, 12, 26)

p position_at(6, 13, 27)
p position_at(6, 13, 28)
# p position_at(6, 1, 6)

# yp_n = yv_i + (yv_i - 1) + (yv_i - 2) + (yv_i - 3) = n * yv_i - n*(n - 1) / 2
#      = n * (yv_i - n/2 + 1/2)
# 0 = n * (yv_i - n/2 + 1/2)
# 0 = yv_i - n/2 + 1/2

# The necessary y velocity in terms of the iteration, if that iteration is zero.
# yv_i = (n - 1)/2

# Given a certain velocity, the iteration at which it will be zero.
# n = 2*yv_i + 1
# A similar formula should exist for the peak.


