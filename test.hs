module Counter where

import Clash.Prelude
import Clash.Explicit.Testbench




-- maskedCounterT :: a -> a -> (a, a)
maskedCounterT acc _input =
    (acc + 1, shift acc (-3))
    

-- maskedCounter :: HiddenClockReset domain gated synchronous =>
--     Signal domain a -> Signal domain a
maskedCounter =
    mealy maskedCounterT 0


{-# ANN topEntity
  (Synthesize
    { t_name   = "counter"
    , t_inputs = [ PortName "clk"
                 ]
    , t_output = PortName "counter_out"
    }) #-}

topEntity
  :: Clock System Source
  -> Reset System Asynchronous
  -> Signal System ()
  -> Signal System (Signed 32)
topEntity = exposeClockReset maskedCounter


