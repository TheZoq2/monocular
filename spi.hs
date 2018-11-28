module Spi where

import Clash.Prelude
import Clash.Explicit.Testbench



data Step
    = Start
    | ClkRising
    | ClkUp
    | ClkDown
    deriving Show


data State = State
    { step :: Step
    , d :: Signed 8
    }


initialState :: State
initialState = State
    { step = Start
    , d = 0
    }


updateStep :: Step -> State -> State
updateStep newStep State {d=d} =
    State newStep d



nextStep :: State -> (Bit, Bit) -> Step
nextStep State {step=step} (clk, input) =
    case step of
        Start ->
            case clk of
                1 -> ClkRising
                _ -> Start
        ClkDown ->
            case clk of
                1 -> ClkRising
                _ -> Start
        ClkRising ->
                ClkUp
        ClkUp ->
            case clk of
                1 -> ClkDown
                _ -> ClkUp


newData :: State -> (Bit, Bit) -> Signed 8
newData State {step=step, d=d} (clk, input) =
    case step of
        ClkRising ->
            shift d 1 + fromInteger (toInteger input)
        _ ->
            d



output :: State -> (Bit, Bit) -> (Signed 8, Bit)
output State {step=step, d=d} (clk, input) =
    case step of
        ClkRising ->
            (d, high)
        _ ->
            (d, low)



spiT :: State -> (Bit, Bit) -> (State, (Signed 8, Bit))
spiT state input =
    ( State {step = nextStep state input, d = newData state input}
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


