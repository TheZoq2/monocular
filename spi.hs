module Spi where

import Clash.Prelude
import Clash.Explicit.Testbench



data Step
    = ClkUp
    | ClkDown
    deriving Show


data State = State
    { step :: Step
    , d :: Signed 8
    , bitsReceived :: Int
    }


initialState :: State
initialState = State
    { step = ClkDown
    , d = 0
    , bitsReceived = 0
    }




nextStep :: State -> (Bit, Bit) -> Step
nextStep State {step=step} (clk, input) =
    case step of
        ClkDown ->
            case clk of
                1 -> ClkUp
                _ -> ClkDown
        ClkUp ->
            case clk of
                1 -> ClkUp
                0 -> ClkDown


updateStateData :: State -> (Bit, Bit) -> State
updateStateData state (clk, input) =
    let
        State {step=step, d=d, bitsReceived=bitsReceived} = state
        newBitsReceived = 
            if bitsReceived == 8 then
                    0
                else
                    bitsReceived
    in
        case step of
            ClkDown ->
                if clk == 1 then
                    state { d = shift d 1 + fromInteger (toInteger input)
                          , bitsReceived = bitsReceived + 1
                          }
                else
                    state {bitsReceived = newBitsReceived}
            _ ->
                state {bitsReceived = newBitsReceived}



output :: State -> (Bit, Bit) -> (Signed 8, Bit)
output State {step=step, d=d, bitsReceived=bitsReceived} (clk, input) =
    (d, if bitsReceived == 8 then 1 else 0)



spiT :: State -> (Bit, Bit) -> (State, (Signed 8, Bit))
spiT state input =
    ( (updateStateData state input) {step = nextStep state input}
    , output state input
    )


-- maskedCounter :: HiddenClockReset domain gated synchronous =>
--     Signal domain a -> Signal domain a
-- spi :: Signal System (Bit, Bit) -> Signal System a
spi =
    mealy spiT initialState


{-# ANN topEntity
  (Synthesize
    { t_name   = "SPIReader"
    , t_inputs = [ PortName "clk"
                 , PortName "rst"
                 , PortProduct "" [PortName "spi_clk", PortName "mosi"]
                 ]
    , t_output = PortProduct "" [PortName "data", PortName "received"]
    }) #-}
topEntity
  :: Clock System Source
  -> Reset System Asynchronous
  -> Signal System (Bit, Bit)
  -> Signal System (Signed 8, Bit)
topEntity = exposeClockReset spi


