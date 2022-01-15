require 'digest'
require 'get_process_mem'

INPUT = File.readlines('./input-day-023.txt')

INT_MAX = 2 ** 62 - 1

lines = INPUT.map(&:strip)

top_raw = lines[2]
bottom_raw = lines[3]

tops = top_raw.gsub('#', '').split(//)
bottoms = bottom_raw.gsub('#', '').split(//)

initial_rooms = tops.zip(bottoms)

##
# CaveStateTwentyThree class.
#
# @type [CaveStateTwentyThree]
#
class CaveStateTwentyThree

  @@fixed = []

  OCCUPANT_AMBER = 'A'
  OCCUPANT_BRONZE = 'B'
  OCCUPANT_COPPER = 'C'
  OCCUPANT_DESERT = 'D'

  OCCUPANT_EMPTY = '.'

  SCUDS_TO_MOVE = [
    OCCUPANT_AMBER,
    OCCUPANT_BRONZE,
    OCCUPANT_COPPER,
    OCCUPANT_DESERT,
  ]

  COST_AMBER = 1
  COST_BRONZE = 10
  COST_COPPER = 100
  COST_DESERT = 1000

  ROOM_INDEX_AMBER = 0
  ROOM_INDEX_BRONZE = 1
  ROOM_INDEX_COPPER = 2
  ROOM_INDEX_DESERT = 3

  ROOM_INDEX_RANGE = Range.new(ROOM_INDEX_AMBER, ROOM_INDEX_DESERT)

  HALF_INDEX_FRONT = 0
  HALF_INDEX_BACK = 1

  ROOM_HALF_INDEX_RANGE = Range.new(HALF_INDEX_FRONT, HALF_INDEX_BACK)

  HALL_INDEX_LLL = 0
  HALL_INDEX_LL = 1
  HALL_INDEX_AMBER = 2
  HALL_INDEX_L = 3
  HALL_INDEX_BRONZE = 4
  HALL_INDEX_C = 5
  HALL_INDEX_COPPER = 6
  HALL_INDEX_R = 7
  HALL_INDEX_DESERT = 8
  HALL_INDEX_RR = 9
  HALL_INDEX_RRR = 10

  HALL_INDICES_FOR_ROOM = [
    HALL_INDEX_AMBER,
    HALL_INDEX_BRONZE,
    HALL_INDEX_COPPER,
    HALL_INDEX_DESERT,
  ]

  HALL_INDEX_RANGE = Range.new(HALL_INDEX_LLL, HALL_INDEX_RRR)

  EMPTY_HALLWAY = Array.new(HALL_INDEX_RANGE.size, OCCUPANT_EMPTY)

  FINISHED_ROOMS = [
    Array.new(ROOM_HALF_INDEX_RANGE.size, CaveStateTwentyThree::OCCUPANT_AMBER.downcase),
    Array.new(ROOM_HALF_INDEX_RANGE.size, CaveStateTwentyThree::OCCUPANT_BRONZE.downcase),
    Array.new(ROOM_HALF_INDEX_RANGE.size, CaveStateTwentyThree::OCCUPANT_COPPER.downcase),
    Array.new(ROOM_HALF_INDEX_RANGE.size, CaveStateTwentyThree::OCCUPANT_DESERT.downcase),
  ]

  def initialize(rooms, hallway)
    @rooms = rooms
    @hallway = hallway
  end

  def self.from_id(unique_id)
    hallway_string, rooms_string = unique_id.split('|')
    new(rooms_from_string(rooms_string), hallway_from_string(hallway_string))
  end

  def self.proper_scud_for_room_index(room_index)
    case room_index
    when ROOM_INDEX_AMBER
      OCCUPANT_AMBER
    when ROOM_INDEX_BRONZE
      OCCUPANT_BRONZE
    when ROOM_INDEX_COPPER
      OCCUPANT_COPPER
    when ROOM_INDEX_DESERT
      OCCUPANT_DESERT
    else
      raise 'wat'
    end
  end

  def self.proper_room_index_for_scud(scud)
    case scud
    when OCCUPANT_AMBER
      ROOM_INDEX_AMBER
    when OCCUPANT_BRONZE
      ROOM_INDEX_BRONZE
    when OCCUPANT_COPPER
      ROOM_INDEX_COPPER
    when OCCUPANT_DESERT
      ROOM_INDEX_DESERT
    else
      raise 'wat'
    end
  end

  def id
    CaveStateTwentyThree.build_id(@hallway, @rooms)
  end

  def self.rooms_from_string(rooms_string)
    [
      [rooms_string[0], rooms_string[1]],
      [rooms_string[2], rooms_string[3]],
      [rooms_string[4], rooms_string[5]],
      [rooms_string[6], rooms_string[7]],
    ]
  end

  def self.hallway_from_string(hallway_string)
    hallway_string.split(//)
  end

  def self.rooms_to_string(rooms)
    rooms.flatten.join('')
  end

  def self.hallway_to_string(hallway)
    hallway.join('')
  end

  def self.build_id(hallway, rooms)
    "#{hallway_to_string(hallway)}|#{rooms_to_string(rooms)}"
  end

  def set_local_energy(energy)
    @local_energy = energy
  end

  def get_local_energy
    @local_energy
  end

  def self.get_energy_rate_for_scud(scud)
    case scud
    when OCCUPANT_AMBER
      COST_AMBER
    when OCCUPANT_BRONZE
      COST_BRONZE
    when OCCUPANT_COPPER
      COST_COPPER
    when OCCUPANT_DESERT
      COST_DESERT
    else
      raise 'wat'
    end
  end

  def get_next_states
    get_outward_next_states + get_inward_next_states
  end

  # @return [Array<CaveStateTwentyThree>]
  def get_outward_next_states
    # Start with each room.
    # A given room position will be fixed if the color of the scud matches that of the room.
    # We'll start with the leftmost room and move to the right. For each room we'll start with the front half.
    next_states = []

    ROOM_INDEX_RANGE.each do |room_index|
      current_hallway_index = CaveStateTwentyThree.room_index_to_hallway_index(room_index)
      available_hallway_indices = CaveStateTwentyThree.available_hallway_indices_from_room_index(@hallway, room_index)
      ROOM_HALF_INDEX_RANGE.each do |half_index|
        # If the scud is settled, we can skip.
        if scud_is_movable?(room_index, half_index)
          # This scud should be able to travel to all available rooms.
          # For each room it travels to, we will have a new hallway.
          new_rooms = CaveStateTwentyThree.rooms_with_scud_removed_at(@rooms, room_index, half_index)

          scud_to_place = scud_at(room_index, half_index)
          available_hallway_indices.each do |available_hallway_index|

            new_hallway = CaveStateTwentyThree.hallway_with_scud_placed_at(@hallway, scud_to_place, available_hallway_index)

            next_state = CaveStateTwentyThree.new(new_rooms, new_hallway)

            # What was the energy required to reach this state?
            number_of_steps = (available_hallway_index - current_hallway_index).abs + (1 + half_index)
            local_energy = CaveStateTwentyThree.get_energy_rate_for_scud(scud_to_place) * number_of_steps

            next_state.set_local_energy(local_energy)

            next_states.push(next_state)
          end
        end
      end
    end

    next_states
  end

  def get_inward_next_states
    # Start with each hall index.
    # Each occupant may *only* move to its matching slot, if available.
    # Otherwise, there are no next states.
    next_states = []

    HALL_INDEX_RANGE.each do |hallway_index|
      occupant = @hallway[hallway_index]
      unless occupant == OCCUPANT_EMPTY
        scud_to_place = occupant
        # Where does this occupant want to go?
        desired_room_index = CaveStateTwentyThree.proper_room_index_for_scud(scud_to_place)
        available_room_indices = CaveStateTwentyThree.available_room_indices_from_hallway_index(@hallway, hallway_index)

        if available_room_indices.include?(desired_room_index)
          # The occupant can only be placed in the back if both back and front is empty, or the front if the front is empty and
          # the back is not empty.
          expected_scud = CaveStateTwentyThree.proper_scud_for_room_index(desired_room_index)
          front_scud = scud_at(desired_room_index, HALF_INDEX_FRONT)
          back_scud = scud_at(desired_room_index, HALF_INDEX_BACK)
          if front_scud == OCCUPANT_EMPTY && (back_scud == OCCUPANT_EMPTY || back_scud == expected_scud.downcase)
            target_room_index = desired_room_index
            if back_scud == OCCUPANT_EMPTY
              target_half_index = HALF_INDEX_BACK
            else
              target_half_index = HALF_INDEX_FRONT
            end
            # Get new hallway
            new_hallway = CaveStateTwentyThree.hallway_with_scud_removed_at(@hallway, hallway_index)
            # Get new rooms, use lowercase to place scud.
            new_rooms = CaveStateTwentyThree.rooms_with_scud_placed_at(@rooms, scud_to_place.downcase, target_room_index, target_half_index)

            next_state = CaveStateTwentyThree.new(new_rooms, new_hallway)

            # What was the energy required to reach this state?
            number_of_steps = (hallway_index - CaveStateTwentyThree.room_index_to_hallway_index(target_room_index)).abs + (1 + target_half_index)
            local_energy = CaveStateTwentyThree.get_energy_rate_for_scud(scud_to_place) * number_of_steps

            next_state.set_local_energy(local_energy)

            next_states.push(next_state)
          end
        end
      end
    end

    next_states
  end

  def self.rooms_with_scud_removed_at(rooms, room_index_to_remove, half_index_to_remove)
    rooms_with_scud_placed_at(rooms, OCCUPANT_EMPTY, room_index_to_remove, half_index_to_remove)
  end

  def self.array_copy_with_new_item_at_index(array, item, index)
    new_array = array.dup
    new_array[index] = item

    new_array
  end

  def self.rooms_with_scud_placed_at(rooms, new_occupant, room_index_to_place, half_index_to_place)
    CaveStateTwentyThree.array_copy_with_new_item_at_index(rooms, CaveStateTwentyThree.array_copy_with_new_item_at_index(rooms[room_index_to_place], new_occupant, half_index_to_place), room_index_to_place)
  end

  def self.hallway_with_scud_removed_at(hallway, hallway_index_to_remove)
    hallway_with_scud_placed_at(hallway, OCCUPANT_EMPTY, hallway_index_to_remove)
  end

  def self.hallway_with_scud_placed_at(hallway, new_occupant, hallway_index_to_place)
    CaveStateTwentyThree.array_copy_with_new_item_at_index(hallway, new_occupant, hallway_index_to_place)
  end

  def self.available_room_indices_from_hallway_index(hallway, hallway_index)
    available_hallway_indices = available_hallway_indices_from_hallway_index(hallway, hallway_index).select do |index|
      HALL_INDICES_FOR_ROOM.include?(index)
    end

    available_hallway_indices.map do |available_hallway_index|
      self.hallway_index_to_room_index(available_hallway_index)
    end
  end

  def self.available_hallway_indices_from_hallway_index(hallway, hallway_index)
    left_indices = Range.new(HALL_INDEX_LLL, hallway_index - 1)
    right_indices = Range.new(hallway_index + 1, HALL_INDEX_RRR)

    available_left = []
    left_indices.reverse_each do |left_index|
      if hallway[left_index] == OCCUPANT_EMPTY
        available_left.unshift(left_index)
      else
        break
      end
    end

    available_right = []
    right_indices.each do |right_index|
      if hallway[right_index] == OCCUPANT_EMPTY
        available_right.push(right_index)
      else
        break
      end
    end

    available_left + available_right
  end

  def self.available_hallway_indices_from_room_index(hallway, room_index)
    available_hallway_indices_from_hallway_index(hallway, room_index_to_hallway_index(room_index)).reject do |index|
      HALL_INDICES_FOR_ROOM.include?(index)
    end
  end

  def self.room_index_to_hallway_index(room_index)
    case room_index
    when ROOM_INDEX_AMBER
      HALL_INDEX_AMBER
    when ROOM_INDEX_BRONZE
      HALL_INDEX_BRONZE
    when ROOM_INDEX_COPPER
      HALL_INDEX_COPPER
    when ROOM_INDEX_DESERT
      HALL_INDEX_DESERT
    else
      raise 'wat'
    end
  end

  def self.hallway_index_to_room_index(hallway_index)
    case hallway_index
    when HALL_INDEX_AMBER
      ROOM_INDEX_AMBER
    when HALL_INDEX_BRONZE
      ROOM_INDEX_BRONZE
    when HALL_INDEX_COPPER
      ROOM_INDEX_COPPER
    when HALL_INDEX_DESERT
      ROOM_INDEX_DESERT
    else
      raise 'wat'
    end
  end

  def scud_at(room_index, half_index)
    @rooms[room_index][half_index]
  end

  def scud_is_movable?(room_index, half_index)
    existing_scud = scud_at(room_index, half_index)

    non_empty = existing_scud != OCCUPANT_EMPTY
    not_fixed = SCUDS_TO_MOVE.include?(existing_scud)

    if half_index == HALF_INDEX_FRONT
      not_trapped = true
    elsif half_index == HALF_INDEX_BACK
      not_trapped = scud_at(room_index, HALF_INDEX_FRONT) == OCCUPANT_EMPTY
    else
      raise 'wat'
    end

    non_empty && not_fixed && not_trapped
  end

end

##
# NavigatorTwentyThree class.
#
# @type [NavigatorTwentyThree]
#
class NavigatorTwentyThree

  attr_accessor :denoted_and_unvisited

  def initialize
    @total_energies = Hash.new { INT_MAX }
    @parents = Hash.new { nil }
    @denoted_and_unvisited = []
    @visited = Hash.new { false }
  end

  # @return [CaveStateTwentyThree, nil]
  def get_next_unvisited
    args = @denoted_and_unvisited.min do |a, b|
      get_total_energy_by_id(a[0]) <=> get_total_energy_by_id(b[0])
    end

    @denoted_and_unvisited.delete(args)

    instance = CaveStateTwentyThree.from_id(args[0])
    instance.set_local_energy(args[1])
    instance
  end

  # @param [CaveStateTwentyThree] state
  def has_been_visited?(state)
    @visited[state.id]
  end

  # @param [CaveStateTwentyThree] state
  # @param [Integer] total_energy
  def denote_total_energy(state, total_energy)
    @total_energies[state.id] = total_energy
    @denoted_and_unvisited.push([state.id, state.get_local_energy])
  end

  # @param [CaveStateTwentyThree] state
  # @return [Integer]
  def get_total_energy(state)
    @total_energies[state.id]
  end

  # @return [Integer]
  def get_total_energy_by_id(state_id)
    @total_energies[state_id]
  end

  # @param [CaveStateTwentyThree] parent_state
  # @param [CaveStateTwentyThree] state
  def denote_parent(state, parent_state)
    @parents[state.id] = parent_state.id
  end

  # @param [CaveStateTwentyThree] state
  def denote_visited(state)
    @visited[state.id] = true
  end

end

# When we are finished, we are looking for this sort of identifier.
final_state = CaveStateTwentyThree.from_id(CaveStateTwentyThree.build_id(CaveStateTwentyThree::EMPTY_HALLWAY, CaveStateTwentyThree::FINISHED_ROOMS))
final_id = final_state.id

root = CaveStateTwentyThree.from_id(CaveStateTwentyThree.build_id(CaveStateTwentyThree::EMPTY_HALLWAY, initial_rooms))

finished = true
return

# @type [NavigatorTwentyThree]
nav = NavigatorTwentyThree.new

# Denote initial energy at starting point.
nav.denote_total_energy(root, 0)

i = 0

mem = GetProcessMem.new

until finished
  # @type [CaveStateTwentyThree]
  current_state = nav.get_next_unvisited

  if i % 1000 == 0
    pp mem.mb
    pp nav.denoted_and_unvisited.count
    pp current_state.id
  end

  # Are we out of states to visit? Or have we reached the ending state? Then we may exit.
  if current_state.nil? || current_state.id == final_id
    finished = true
  else
    # Only get states that we have not visited.
    next_states_to_visit = current_state.get_next_states.reject { |next_state| nav.has_been_visited?(next_state) }

    next_states_to_visit.each do |next_state|

      # Calculate potential energy.
      potential_energy = nav.get_total_energy(current_state) + next_state.get_local_energy

      # Set new energy if less.
      if potential_energy < nav.get_total_energy(next_state)
        nav.denote_total_energy(next_state, potential_energy)
        nav.denote_parent(next_state, current_state)
      end
    end

    nav.denote_visited(current_state)
  end

  i += 1
end

pp nav.get_total_energy(current_state)


