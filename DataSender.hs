module DataSender where

import Clash.Prelude
import Clash.Explicit.Testbench


type Input = (Unsigned 40, Bit, Bit)
type Output = (Unsigned 8)


data Step
    -- Continuously reading data and waiting for transmission to start
    = Waiting
    -- Transmiting data, `n` bytes left
    | Transmiting Int
    deriving (Eq)


data State = State
    { d :: Unsigned 40
    , step :: Step
    }

initialState = State
    { d = 0
    , step = Waiting
    }


updateState :: Input -> State -> State
updateState (inD, transmissionDone, transmissionStart) state =
    let
        State {step=step, d=currentD} = state
        newStep =
            case step of
                Waiting ->
                    if transmissionStart == high then
                        Transmiting 4
                    else
                        Waiting
                Transmiting 0 ->
                    Waiting
                Transmiting n ->
                    if transmissionDone == high then
                        Transmiting (n - 1)
                    else
                        Transmiting n

        newD =
            case step of
                Waiting ->
                    inD
                Transmiting _ ->
                    if transmissionDone == high then
                        rotateR currentD 8
                    else
                        currentD
    in
        state {step = newStep, d = newD}

output :: Input -> State -> Output
output input State {d=d} =
    (truncateB $ d :: Unsigned 8)


dataSenderT :: State -> Input -> (State, Output)
dataSenderT state input =
    ( updateState input state
    , output input state
    )




dataSender =
    mealy dataSenderT initialState


{-# ANN topEntity
  (Synthesize
    { t_name   = "DataSender"
    , t_inputs = [ PortName "clk"
                 , PortName "rst"
                 , PortProduct ""
                    [ PortName "dataIn"
                    , PortName "transmissionDone"
                    , PortName "transmissionStart"
                    ]
                 ]
    , t_output = PortName "dataOut" 
    }) #-}
topEntity
  :: Clock System Source
  -> Reset System Asynchronous
  -> Signal System Input
  -> Signal System Output
topEntity = exposeClockReset dataSender

