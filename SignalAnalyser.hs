module SignalAnalyser where

import Clash.Prelude
import Clash.Explicit.Testbench


data State a = State
    { time :: Unsigned 32
    , d :: a
    }


initialState = State 0 0



data Input a = Input
    { newData :: a }




updateState :: Input a -> State a -> State a
updateState (Input newData) state =
    state { d = newData
        , time = (time state + 1)
        }



output :: Eq a => Input a -> State a -> (Unsigned 32, a, Bit)
output (Input newData) State {d=d, time=time} =
    (time, d, unpack $ pack (newData /= d))



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
                 , PortProduct ""
                    [ PortName "data_in"
                    ]
                 ]
    , t_output = PortProduct "" 
        [ PortName "currentTime"
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


