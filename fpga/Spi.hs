module Spi where

import Clash.Prelude
import Clash.Explicit.Testbench



data Step
    = NoTransmission
    | TransmissionDone
    | ClkRising (Unsigned 8)
    | ClkUp (Unsigned 8)
    | ClkDown (Unsigned 8)
    | ClkFalling (Unsigned 8)
    deriving (Show, Eq)


data Input = Input
    { clk :: Bit
    , mosi :: Bit
    , toOutput :: Unsigned 8
    }

data State = State
    { step :: Step
    , received :: Unsigned 8
    , toTransmit :: Unsigned 8
    } deriving Show


initialState :: State
initialState = State
    { step = NoTransmission
    , received = 0
    , toTransmit = 0b10101011
    }




{-
  Calculates the next step from the current input
-}
nextStep :: State -> Input -> Step
nextStep State {step=step} (Input clk input toOutput) =
    case step of
        NoTransmission ->
            case clk of
                1 -> ClkRising 0
                _ -> NoTransmission
        TransmissionDone ->
            case clk of
                1 -> ClkRising 0
                _ -> NoTransmission
        ClkFalling amount ->
            if amount == 7 then
                TransmissionDone
            else
                case clk of
                    1 -> ClkRising (amount + 1)
                    _ -> ClkDown (amount + 1)
        ClkDown amount ->
            case clk of
                1 -> ClkRising amount
                _ -> ClkDown amount
        ClkRising amount ->
            case clk of
                1 -> ClkUp amount
                _ -> ClkFalling amount
        ClkUp amount ->
            case clk of
                1 -> ClkUp amount
                _ -> ClkFalling amount


{-
  Updates the input data from the current state
-}
updateStateData :: State -> Input -> State
updateStateData state (Input clk input toOutput) =
    let
        State {step=step, received=received} = state
    in
        case step of
            ClkRising _ ->
                state { received = shift received 1 + fromInteger (toInteger input) }
            _ ->
                state


updateStateOutput :: Input -> State -> State
updateStateOutput (Input clk input toOutput) state =
    case step state of
        ClkFalling _ ->
            state {toTransmit = rotateL (toTransmit state) 1}
        NoTransmission ->
            state {toTransmit = toOutput}
        TransmissionDone ->
            state {toTransmit = toOutput}
        _ ->
            state



output :: State -> Input -> (Unsigned 8, Bit, Bit, Bit, Bit)
output State {step=step, received=received, toTransmit=toTransmit} input =
    let
        amount = case step of
            NoTransmission -> 255
            TransmissionDone -> 255
            ClkFalling amount -> amount
            ClkDown amount -> amount
            ClkRising amount -> amount
            ClkUp amount -> amount
    in
    ( received
    , if step == TransmissionDone then 1 else 0 , msb (toTransmit :: Unsigned 8)
    , if step == ClkRising 0 then 1 else 0
    , case step of
          ClkFalling _ -> 0
          ClkDown _ -> 0
          TransmissionDone -> 1
          NoTransmission -> 1
          _ -> 0
    )



spiT :: State -> (Bit, Bit, Unsigned 8) -> (State, (Unsigned 8, Bit, Bit, Bit, Bit))
spiT state (clk, mosi, toOutput) =
    let
        input = Input clk mosi toOutput

        newState =
            (updateStateData (updateStateOutput input state) input) {step = nextStep state input}
    in
        ( newState
        , output newState input
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
                 , PortProduct ""
                    [ PortName "spi_clk"
                    , PortName "mosi"
                    , PortName "to_output"
                    ]
                 ]
    , t_output = PortProduct "" 
        [ PortName "data"
        , PortName "received"
        , PortName "miso"
        , PortName "transmission_started"
        , PortName "debug"
        ]
    }) #-}
topEntity
  :: Clock System Source
  -> Reset System Asynchronous
  -> Signal System (Bit, Bit, Unsigned 8)
  -> Signal System (Unsigned 8, Bit, Bit, Bit, Bit)
topEntity = exposeClockReset spi




