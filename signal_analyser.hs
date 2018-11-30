module SignalAnalyser where

import Clash.Prelude
import Clash.Explicit.Testbench



data State a = State a
    { time :: Unsigned 32
    , d :: a
    }


initialState :: State 0 0



data Input a = Input a
    { newData :: a }




updateState :: Input a -> State a -> State a
updateState (Input newData) state =
    state
        { newData = newData
        , time = (time state + 1)
        }



output :: Input a -> State a -> (Unsigned 32, a, Bit)
output (Input newData) State {d=d, time=time} =
    (time, d, newData != d)



signalAnalyserT :: State a -> a -> (State a, (Unsigned 32, a, Bit))
signalAnalyserT state input =
    ( updateState (Input input) state
    , output (Input input) state
    )
