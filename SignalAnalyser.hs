module SignalAnalyser where

import Clash.Prelude
import Clash.Explicit.Testbench


data Step
    = Initial
    | NewData
    deriving (Eq)

data State a = State
    { time :: Unsigned 32
    , d :: a
    , dataTime :: Unsigned 32
    , step :: Step
    }


initialState = State 0 0 0 Initial



data Input a = Input
    { newData :: a }



isNewData :: Eq a => a -> a -> Bool
isNewData old new =
    old /= new



updateState :: Eq a => Input a -> State a -> State a
updateState (Input newData) state =
    let
        trans = isNewData newData (d state)
    in
        state
            { d = newData
            , time = (time state + 1)
            , dataTime =
                if trans then
                    time state
                else
                    dataTime state
            , step =
                if trans then
                    NewData
                else
                    Initial
            }



output :: Eq a => Input a -> State a -> (Unsigned 32, a, Bit)
output (Input newData) State {d=d, dataTime=dataTime, step=step} =
    (dataTime, d, unpack $ pack (step == NewData))



signalAnalyserT :: Eq a => State a -> a -> (State a, (Unsigned 32, a, Bit))
signalAnalyserT state input =
    ( updateState (Input input) state
    , output (Input input) state
    )




signalAnalyser =
    mealy signalAnalyserT initialState




{-# ANN topEntity
  (Synthesize
    { t_name   = "signal_analyser"
    , t_inputs = [ PortName "clk"
                 , PortName "rst"
                 , PortName "dataIn"
                 ]
    , t_output = PortProduct "" 
        [ PortName "dataTime"
        , PortName "dataOut"
        , PortName "newData"
        ]
    }) #-}
topEntity
  :: Clock System Source
  -> Reset System Asynchronous
  -> Signal System (Unsigned 8)
  -> Signal System (Unsigned 32, Unsigned 8, Bit)
topEntity = exposeClockReset signalAnalyser


