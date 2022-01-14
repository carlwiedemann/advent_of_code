require 'digest'

INPUT = File.readlines('./input-day-023.txt')

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

  AMBER = 'A'
  BRONZE = 'B'
  COPPER = 'C'
  DESERT = 'D'

  EMPTY = nil

  ROOM_AMBER = 0
  ROOM_BRONZE = 1
  ROOM_COPPER = 2
  ROOM_DESERT = 3

  ROOM_RANGE = Range.new(ROOM_AMBER, ROOM_DESERT)

  HALF_FRONT = 0
  HALF_BACK = 1

  ROOM_HALF_RANGE = Range.new(HALF_FRONT, HALF_BACK)

  HALL_LLL = 0
  HALL_LL = 1
  HALL_L = 2
  HALL_C = 3
  HALL_R = 4
  HALL_RR = 5
  HALL_RRR = 6

  HALL_RANGE = Range.new(HALL_LLL, HALL_RRR)

  EMPTY_HALLWAY = Array.new(7, EMPTY)

  FINISHED_ROOMS = [
    Array.new(2, CaveStateTwentyThree::AMBER),
    Array.new(2, CaveStateTwentyThree::BRONZE),
    Array.new(2, CaveStateTwentyThree::COPPER),
    Array.new(2, CaveStateTwentyThree::DESERT),
  ]

  FINISHED_ARGS = [
    FINISHED_ROOMS,
    EMPTY_HALLWAY,
  ]

  def initialize(rooms, hallway)
    @rooms = rooms
    @hallway = hallway
  end

  def self.proper_scud(room)
    case room
    when ROOM_AMBER
      AMBER
    when ROOM_BRONZE
      BRONZE
    when ROOM_COPPER
      COPPER
    when ROOM_DESERT
      DESERT
    else
      raise 'wat'
    end
  end

  def to_args
    [
      @rooms,
      @hallway,
    ]
  end

  def unique_id
    Digest::MD5.hexdigest("#{@rooms.to_s}:#{@hallway.to_s}")
  end

  def set_local_energy(energy)
    @local_energy = energy
  end

  def get_local_energy
    @local_energy
  end

  # @return [Array<CaveStateTwentyThree>]
  def next_states
    # Determine all possible next states.
    # Start with each room.
    # A given room position will be fixed if the color of the scud matches that of the room.
    # We'll start with the leftmost room and move to the right. For each room we'll start with the front half.
    ROOM_RANGE.each do |room|
      ROOM_HALF_RANGE.each do |half|
        pp "#{room.to_s} #{half.to_s}"
        pp is_fixed?(room, half)
      end
    end

    []
  end

  def is_fixed?(room, half)
    @rooms[room][half] == CaveStateTwentyThree.proper_scud(room)
  end

end

##
# NavigatorTwentyThree class.
#
# @type [NavigatorTwentyThree]
#
class NavigatorTwentyThree

  # @return [CaveStateTwentyThree]
  def get_next_unvisited

  end

  # @param [CaveStateTwentyThree] state
  def has_been_visited?(state) end

  # @param [CaveStateTwentyThree] state
  # @param [Integer] total_energy
  def denote_total_energy(state, total_energy)
    # code here
  end

  # @param [CaveStateTwentyThree] state
  def get_total_energy(state)
    # code here
  end

  # @param [CaveStateTwentyThree] parent_state
  # @param [CaveStateTwentyThree] state
  def denote_parent(state, parent_state) end

  def resort_denoted

  end

  # @param [CaveStateTwentyThree] state
  def denote_visited(state) end

end

# When we are finished, we are looking for this sort of identifier.
final_id = CaveStateTwentyThree.new(*CaveStateTwentyThree::FINISHED_ARGS).unique_id

root = CaveStateTwentyThree.new(initial_rooms, CaveStateTwentyThree::EMPTY_HALLWAY)

finished = true

# @type [NavigatorTwentyThree]
nav = NavigatorTwentyThree.new

# Denote initial energy at starting point.
nav.denote_total_energy(root, 0)

until finished
  # @type [CaveStateTwentyThree]
  state = nav.get_next_unvisited

  # Are we out of states to visit? Or have we reached the ending state? Then we may exit.
  if state.nil? || state.unique_id == final_id
    finished = true
  else
    # Only get states that we have not visited.
    next_states_to_visit = state.next_states.reject { |next_state| nav.has_been_visited?(next_state) }

    resort = false
    next_states_to_visit.each do |next_state_to_visit|

      # Calculate potential energy.
      potential_energy = nav.get_total_energy(state) + next_state_to_visit.get_local_energy

      # Set new energy if less.
      if potential_energy < nav.get_total_energy(next_state_to_visit)
        nav.denote_total_energy(next_state_to_visit, potential_energy)
        nav.denote_parent(next_state_to_visit, state)
        resort = true
      end
    end

    # If we denoted anything, we should resort it.
    nav.resort_denoted if resort

  end

  nav.denote_visited(state)
end



