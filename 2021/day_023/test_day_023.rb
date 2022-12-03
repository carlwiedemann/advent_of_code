require_relative 'solution_day_023'
require 'get_process_mem'

def assert(actual, expected)
  if actual != expected
    raise "expected #{expected}; received #{actual}"
  end
end

test1 = lambda do

  # Cave with A and B switched in front room.
  s = CaveStateTwentyThree.from_id('...........|BAABCCDD')

  next_states = s.get_outward_next_states

  assert(next_states[0].id, 'B..........|.AABCCDD')
  assert(next_states[0].get_local_energy, 30)

  assert(next_states[1].id, '.B.........|.AABCCDD')
  assert(next_states[1].get_local_energy, 20)

  assert(next_states[2].id, '...B.......|.AABCCDD')
  assert(next_states[2].get_local_energy, 20)

  assert(next_states[3].id, '.....B.....|.AABCCDD')
  assert(next_states[3].get_local_energy, 40)

  assert(next_states[4].id, '.......B...|.AABCCDD')
  assert(next_states[4].get_local_energy, 60)

  assert(next_states[5].id, '.........B.|.AABCCDD')
  assert(next_states[5].get_local_energy, 80)

  assert(next_states[6].id, '..........B|.AABCCDD')
  assert(next_states[6].get_local_energy, 90)

  assert(next_states[7].id, 'A..........|BA.BCCDD')
  assert(next_states[7].get_local_energy, 5)

  assert(next_states[8].id, '.A.........|BA.BCCDD')
  assert(next_states[8].get_local_energy, 4)

  assert(next_states[9].id, '...A.......|BA.BCCDD')
  assert(next_states[9].get_local_energy, 2)

  assert(next_states[10].id, '.....A.....|BA.BCCDD')
  assert(next_states[10].get_local_energy, 2)

  assert(next_states[11].id, '.......A...|BA.BCCDD')
  assert(next_states[11].get_local_energy, 4)

  assert(next_states[12].id, '.........A.|BA.BCCDD')
  assert(next_states[12].get_local_energy, 6)

  assert(next_states[13].id, '..........A|BA.BCCDD')
  assert(next_states[13].get_local_energy, 7)
end

test2 = lambda do
  assert(CaveStateTwentyThree.proper_scud_for_room_index(CaveStateTwentyThree::ROOM_INDEX_AMBER), CaveStateTwentyThree::SCUD_AMBER)
  assert(CaveStateTwentyThree.proper_scud_for_room_index(CaveStateTwentyThree::ROOM_INDEX_BRONZE), CaveStateTwentyThree::SCUD_BRONZE)
  assert(CaveStateTwentyThree.proper_scud_for_room_index(CaveStateTwentyThree::ROOM_INDEX_COPPER), CaveStateTwentyThree::SCUD_COPPER)
  assert(CaveStateTwentyThree.proper_scud_for_room_index(CaveStateTwentyThree::ROOM_INDEX_DESERT), CaveStateTwentyThree::SCUD_DESERT)
end

test3 = lambda do
  assert(CaveStateTwentyThree.get_energy_rate_for_scud(CaveStateTwentyThree::SCUD_AMBER), 1)
  assert(CaveStateTwentyThree.get_energy_rate_for_scud(CaveStateTwentyThree::SCUD_BRONZE), 10)
  assert(CaveStateTwentyThree.get_energy_rate_for_scud(CaveStateTwentyThree::SCUD_COPPER), 100)
  assert(CaveStateTwentyThree.get_energy_rate_for_scud(CaveStateTwentyThree::SCUD_DESERT), 1000)
end

test4 = lambda do
  rooms = CaveStateTwentyThree.rooms_from_string('AABBCCDD')

  new_rooms = CaveStateTwentyThree.rooms_with_scud_placed_at(rooms, 'X', CaveStateTwentyThree::ROOM_INDEX_BRONZE, 0)
  new_room_string = CaveStateTwentyThree.rooms_to_string(new_rooms)
  assert(new_room_string, 'AAXBCCDD')

  new_rooms = CaveStateTwentyThree.rooms_with_scud_placed_at(rooms, 'X', CaveStateTwentyThree::ROOM_INDEX_COPPER, 1)
  new_room_string = CaveStateTwentyThree.rooms_to_string(new_rooms)
  assert(new_room_string, 'AABBCXDD')

  new_rooms = CaveStateTwentyThree.rooms_with_scud_removed_at(rooms, CaveStateTwentyThree::ROOM_INDEX_BRONZE, 0)
  new_room_string = CaveStateTwentyThree.rooms_to_string(new_rooms)
  assert(new_room_string, 'AA.BCCDD')

  new_rooms = CaveStateTwentyThree.rooms_with_scud_removed_at(rooms, CaveStateTwentyThree::ROOM_INDEX_COPPER, 1)
  new_room_string = CaveStateTwentyThree.rooms_to_string(new_rooms)
  assert(new_room_string, 'AABBC.DD')

  hallway = CaveStateTwentyThree.hallway_from_string('.A.......B.')

  new_hallway = CaveStateTwentyThree.hallway_with_scud_placed_at(hallway, 'X', CaveStateTwentyThree::HALL_INDEX_LLL)
  new_hallway_string = CaveStateTwentyThree.hallway_to_string(new_hallway)
  assert(new_hallway_string, 'XA.......B.')

  new_hallway = CaveStateTwentyThree.hallway_with_scud_placed_at(hallway, 'X', CaveStateTwentyThree::HALL_INDEX_RRR)
  new_hallway_string = CaveStateTwentyThree.hallway_to_string(new_hallway)
  assert(new_hallway_string, '.A.......BX')

  new_hallway = CaveStateTwentyThree.hallway_with_scud_removed_at(hallway, CaveStateTwentyThree::HALL_INDEX_LL)
  new_hallway_string = CaveStateTwentyThree.hallway_to_string(new_hallway)
  assert(new_hallway_string, '.........B.')

  new_hallway = CaveStateTwentyThree.hallway_with_scud_removed_at(hallway, CaveStateTwentyThree::HALL_INDEX_RR)
  new_hallway_string = CaveStateTwentyThree.hallway_to_string(new_hallway)
  assert(new_hallway_string, '.A.........')
end

test5 = lambda do
  s = CaveStateTwentyThree.from_id('...B.......|.CACBADD')

  next_states = s.get_outward_next_states

  assert(next_states[0].id, 'C..B.......|..ACBADD')
  assert(next_states[0].get_local_energy, 400)

  assert(next_states[1].id, '.C.B.......|..ACBADD')
  assert(next_states[1].get_local_energy, 300)

  assert(next_states[2].id, '...B.A.....|.C.CBADD')
  assert(next_states[2].get_local_energy, 2)

  assert(next_states[3].id, '...B...A...|.C.CBADD')
  assert(next_states[3].get_local_energy, 4)

  assert(next_states[4].id, '...B.....A.|.C.CBADD')
  assert(next_states[4].get_local_energy, 6)

  assert(next_states[5].id, '...B......A|.C.CBADD')
  assert(next_states[5].get_local_energy, 7)
end

test6 = lambda do
  s = CaveStateTwentyThree.from_id('...B...A...|.C.CBADD')

  next_states = s.get_outward_next_states

  assert(next_states[0].id, 'C..B...A...|...CBADD')
  assert(next_states[0].get_local_energy, 400)

  assert(next_states[1].id, '.C.B...A...|...CBADD')
  assert(next_states[1].get_local_energy, 300)

  assert(next_states[2].id, '...B.C.A...|.C..BADD')
  assert(next_states[2].get_local_energy, 300)

  assert(next_states[3].id, '...B.B.A...|.C.C.ADD')
  assert(next_states[3].get_local_energy, 20)

  assert(next_states[4].id, '...B...A.D.|.C.CBA.D')
  assert(next_states[4].get_local_energy, 2000)

  assert(next_states[5].id, '...B...A..D|.C.CBA.D')
  assert(next_states[5].get_local_energy, 3000)

  assert(next_states.count, 6)
end

test7 = lambda do
  s = CaveStateTwentyThree.from_id('BB.A.A.....|....CCDD')

  next_states = s.get_inward_next_states

  assert(next_states[0].id, 'BB...A.....|.a..CCDD')
  assert(next_states[0].get_local_energy, 3)

  # Iterate
  new_next_states = next_states[0].get_inward_next_states

  assert(new_next_states[0].id, 'B....A.....|.a.bCCDD')
  assert(new_next_states[0].get_local_energy, 50)
end

test8 = lambda do
  s = CaveStateTwentyThree.from_id('...B...A.D.|.C.CBD.A')

  assert(s.scud_is_movable?(CaveStateTwentyThree::ROOM_INDEX_AMBER, 0), false)
  assert(s.scud_is_movable?(CaveStateTwentyThree::ROOM_INDEX_AMBER, 1), true)

  assert(s.scud_is_movable?(CaveStateTwentyThree::ROOM_INDEX_COPPER, 0), true)
  assert(s.scud_is_movable?(CaveStateTwentyThree::ROOM_INDEX_COPPER, 1), false)

  assert(s.scud_is_movable?(CaveStateTwentyThree::ROOM_INDEX_DESERT, 0), false)
  assert(s.scud_is_movable?(CaveStateTwentyThree::ROOM_INDEX_DESERT, 1), false)

  s = CaveStateTwentyThree.from_id('...B...A.D.|.DDDCCCC.BBB.AAA')

  assert(s.scud_is_movable?(CaveStateTwentyThree::ROOM_INDEX_AMBER, CaveStateTwentyThree::SECTION_INDEX_FIRST), false)
  assert(s.scud_is_movable?(CaveStateTwentyThree::ROOM_INDEX_AMBER, CaveStateTwentyThree::SECTION_INDEX_SECOND), true)

  assert(s.scud_is_movable?(CaveStateTwentyThree::ROOM_INDEX_BRONZE, CaveStateTwentyThree::SECTION_INDEX_FIRST), true)
  assert(s.scud_is_movable?(CaveStateTwentyThree::ROOM_INDEX_BRONZE, CaveStateTwentyThree::SECTION_INDEX_SECOND), false)

  assert(s.scud_is_movable?(CaveStateTwentyThree::ROOM_INDEX_DESERT, CaveStateTwentyThree::SECTION_INDEX_FIRST), false)
  assert(s.scud_is_movable?(CaveStateTwentyThree::ROOM_INDEX_DESERT, CaveStateTwentyThree::SECTION_INDEX_SECOND), false)
  assert(s.scud_is_movable?(CaveStateTwentyThree::ROOM_INDEX_DESERT, CaveStateTwentyThree::SECTION_INDEX_THIRD), false)
  assert(s.scud_is_movable?(CaveStateTwentyThree::ROOM_INDEX_DESERT, CaveStateTwentyThree::SECTION_INDEX_FOURTH), false)
end

test1.call
test2.call
test3.call
test4.call
test5.call
test6.call
test7.call
test8.call

pp '### TESTS OK ###'