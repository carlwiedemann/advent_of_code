require_relative 'solution-day-023'

def assert(actual, expected)
  if actual != expected
    raise "expected #{expected}; received #{actual}"
  end
end

test1 = lambda do

  # Cave with A and B switched in front room.
  s = CaveStateTwentyThree.new([
                                 [
                                   CaveStateTwentyThree::BRONZE,
                                   CaveStateTwentyThree::AMBER,
                                 ],
                                 [
                                   CaveStateTwentyThree::AMBER,
                                   CaveStateTwentyThree::BRONZE,
                                 ],
                                 [
                                   CaveStateTwentyThree::COPPER,
                                   CaveStateTwentyThree::COPPER,
                                 ],
                                 [
                                   CaveStateTwentyThree::DESERT,
                                   CaveStateTwentyThree::DESERT,
                                 ],
                               ], CaveStateTwentyThree::EMPTY_HALLWAY)

  # Test some states.
  next_states = s.next_states
  args = next_states[0].to_args

  assert(args[0], [
    [
      CaveStateTwentyThree::EMPTY,
      CaveStateTwentyThree::AMBER,
    ],
    [
      CaveStateTwentyThree::AMBER,
      CaveStateTwentyThree::BRONZE,
    ],
    [
      CaveStateTwentyThree::COPPER,
      CaveStateTwentyThree::COPPER,
    ],
    [
      CaveStateTwentyThree::DESERT,
      CaveStateTwentyThree::DESERT,
    ],
  ])

  assert(args[1], [
    CaveStateTwentyThree::BRONZE,
    CaveStateTwentyThree::EMPTY,
    CaveStateTwentyThree::EMPTY,
    CaveStateTwentyThree::EMPTY,
    CaveStateTwentyThree::EMPTY,
    CaveStateTwentyThree::EMPTY,
    CaveStateTwentyThree::EMPTY,
  ])

end

test2 = lambda do
  assert(CaveStateTwentyThree.proper_scud(CaveStateTwentyThree::ROOM_AMBER), CaveStateTwentyThree::AMBER)
  assert(CaveStateTwentyThree.proper_scud(CaveStateTwentyThree::ROOM_BRONZE), CaveStateTwentyThree::BRONZE)
  assert(CaveStateTwentyThree.proper_scud(CaveStateTwentyThree::ROOM_COPPER), CaveStateTwentyThree::COPPER)
  assert(CaveStateTwentyThree.proper_scud(CaveStateTwentyThree::ROOM_DESERT), CaveStateTwentyThree::DESERT)
end

test1.call
test2.call

pp '### TESTS OK ###'