require 'fiber'
require 'eventmachine'

FIBER_IDXS = {}

def fiber_idx
  FIBER_IDXS[Fiber.current.object_id] ||= FIBER_IDXS.length
end

$order = 0

def ll indent, where, guess, *desc
  info = "#{" "*indent} #{where}"
  puts "%8s %3d\t%-15s\t%-7s\t%-30s\t%-30s\t%s" % [
    Fiber.current.object_id.to_s(16),
    $order,
    guess,
    fiber_idx,
    *(fiber_idx == 0 ? [info, " "*30] : [" "*30, info]),
    desc.join("\t")
  ]
  $order += 1
end

#
# Start reading in the eventmachine block below, then come back here
#

def get_result()
  ll(4, 'beg get_result',      " 6 fiber_1", "get_result is called from within fiber_1")
  f = Fiber.current

  ll(4, 'setup callback',      " 7 fiber_1", "set up some code to run 1.5s from now")
  EM.add_timer(1.5) do
    ll(5, 'beg callback',      "10 fiber_0", "Executed *by the main fiber* 1.5 seconds from now; all non-deferred code from the EventMachine.run{} setup block has happened")

    f.resume(:bob)             #   fiber_0 -- Ha! pick up where the fiber left off, the 'ret = Fiber.yield' line; 'ret' will get the value ':bob'

    ll(5, 'end callback',      "14 fiber_0", "We come back here from the *end of the fiber*: we're now back in the root fiber for good.")
  end

  ll(4, 'bef Fiber.yield',     " 8 fiber_1", "EM.add_timer just stashed the block away, so this runs next.")
  ret = Fiber.yield            #   fiber_1 -- Watchout! this suspends action.

  ll(4, 'end get_result',      "11 fiber_1", "f.resume picks up here when the timer goes off.")
  return ret
end


#
# Start here:
#
ll(0, 'beg main',              " 0 fiber_0", "top level")

EventMachine.run do
  ll(1, 'beg em setup',        " 1 fiber_0", "this block sets up the eventmachine execution, but no execution-order shenanigans yet")

  EM.add_timer(2.5){
    ll(2, "stop runner",       "15 fiber_0", "this will be the *next to last* thing in the program... 2.5s into the future, stop the Eventmachine reactor")
    EM.stop
  }

  ll(2, 'beg fiber setup',     " 2 fiber_0", "the end-the-reactor block won't be called for 1.5s, so we get here immediately.")

  my_fiber = Fiber.new{
    ll(3, 'beg fiber',         " 5 fiber_1", "when my_fiber.resume is called, this runs. Now in a new fiber")

    res = get_result()        #    fiber1 -- get_result is called, but the last thing it does is pause execution

    ll(3, "got it: '#{res}'",  "12 fiber_1", "the line after get_result wast called -- this isn't run until f.resume(:bob) from inside the method.")
    ll(3, "end fiber",         "13 fiber_1", "the get_result function returned; from here, picks up at the line following 'f.resume(:bob)'")
  }

  ll(2, 'end fiber setup',     " 3 fiber_0", "nothing from inside the Fiber.new{} block has run yet.")


  ll(2, 'end fiber setup',     " 4 fiber_0", "kick off the fiber...")
  my_fiber.resume

  ll(1, 'end em setup',        " 9 fiber_0", "the line after my_fiber.resume, picks up when 'ret = Fiber.yield' is called. Now we go into the reactor loop and twiddle our thumbs for 1.5s")
end

ll(0, 'end main',              "16 fiber_0", "done.")
