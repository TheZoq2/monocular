module Spi where

import Clash.Prelude
import Clash.Explicit.Testbench



data Step
    = ClkUp
    | ClkDown
    deriving (Show, Eq)


data Input = Input
    { clk :: Bit
    , mosi :: Bit
    , toOutput :: Unsigned 8
    }

data State = State
    { step :: Step
    , dataIn :: Unsigned 8
    , dataOut :: Unsigned 8
    , outBuffer :: Unsigned 8
    , bitsReceived :: Unsigned 8
    } deriving Show


initialState :: State
initialState = State
    { step = ClkDown
    , dataIn = 0
    , dataOut = 0b10101011
    , outBuffer = 0
    , bitsReceived = 0
    }




{-
  Calculates the next step from the current input
-}
nextStep :: State -> Input -> Step
nextStep State {step=step} (Input clk input toOutput) =
    case step of
        ClkDown ->
            case clk of
                1 -> ClkUp
                _ -> ClkDown
        ClkUp ->
            case clk of
                1 -> ClkUp
                0 -> ClkDown


{-
  Updates the input data from the current state
-}
updateStateData :: State -> Input -> State
updateStateData state (Input clk input toOutput) =
    let
        State {step=step, dataIn=dataIn, bitsReceived=bitsReceived} = state
        newBitsReceived =
            if bitsReceived == 8 then
                    0
                else
                    bitsReceived
    in
        case step of
            ClkDown ->
                if clk == 1 then
                    state { dataIn = shift dataIn 1 + fromInteger (toInteger input)
                          , bitsReceived = bitsReceived + 1
                          }
                else
                    state {bitsReceived = newBitsReceived}
            _ ->
                state {bitsReceived = newBitsReceived}


updateStateOutput :: Input -> State -> State
updateStateOutput (Input clk input toOutput) state =
    let
        State {step=step, bitsReceived=bitsReceived, dataOut=dataOut} = state
        newDataOut =
            if bitsReceived == 0 then
                outBuffer state
            else
                if step == ClkUp && clk == 0 then
                    rotateR dataOut (1)
                else
                    dataOut
    in
        state {dataOut=newDataOut, outBuffer=toOutput}



output :: State -> (Unsigned 8, Bit, Bit)
output State {step=step, dataIn=dataIn, bitsReceived=bitsReceived, dataOut=dataOut} =
    (dataIn, if bitsReceived == 8 then 1 else 0, lsb (dataOut :: Unsigned 8))



spiT :: State -> (Bit, Bit, Unsigned 8) -> (State, (Unsigned 8, Bit, Bit))
spiT state (clk, mosi, toOutput) =
    let
        input = Input clk mosi toOutput

        newState =
            (updateStateData (updateStateOutput input state) input) {step = nextStep state input}
    in
        ( newState
        , output newState
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
                    , PortName "toOutput"
                    ]
                 ]
    , t_output = PortProduct "" 
        [ PortName "data"
        , PortName "received"
        , PortName "miso"
        ]
    }) #-}
topEntity
  :: Clock System Source
  -> Reset System Asynchronous
  -> Signal System (Bit, Bit, Unsigned 8)
  -> Signal System (Unsigned 8, Bit, Bit)
topEntity = exposeClockReset spi


