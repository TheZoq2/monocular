module Counter where

import Clash.Prelude
import Clash.Explicit.Testbench




-- maskedCounterT :: a -> a -> (a, a)
maskedCounterT acc _input =
    (acc + 1, shift acc 20)
    

-- maskedCounter :: HiddenClockReset domain gated synchronous =>
--     Signal domain a -> Signal domain a
maskedCounter =
    mealy maskedCounterT 0


topEntity
  :: Clock System Source
  -> Reset System Asynchronous
  -> Signal System ()
  -> Signal System (Signed 32)
topEntity = exposeClockReset maskedCounter




