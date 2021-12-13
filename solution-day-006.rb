INPUT = File.readlines('./input-day-006.txt')
fishes = INPUT.map(&:strip).pop.to_s.split(',').map(&:to_i)

DAYS = 256
DOUBLE = 7

def number_of_descendants(lifetime_length, until_fertile, nest = 0)
  @_cache = {} unless @_cache
  _cache_key = "#{lifetime_length}:#{until_fertile}"

  unless @_cache[_cache_key]

    fertile_length = (lifetime_length - until_fertile)
    if fertile_length > 0
      direct_children = (fertile_length / DOUBLE.to_f).ceil

      progeny = direct_children.times.map do |i|
        child_lifetime = fertile_length - i * DOUBLE - 1
        number_of_descendants(child_lifetime, 8, nest + 1)
      end
    else
      direct_children = 0
      progeny = []
    end

    if progeny.length > 0
      descendants = direct_children + progeny.reduce(&:+)
    else
      descendants = direct_children
    end

    @_cache[_cache_key] = descendants
  end

  @_cache[_cache_key]
end

family_totals = fishes.map do |fish_index|
  1 + number_of_descendants(DAYS, fish_index)
end

recursive_final = family_totals.reduce(&:+)

p "recursive_final"
p recursive_final
