module SignalAnalyser where

import Clash.Prelude
import Clash.Explicit.Testbench


data Step
    = Initial
    | NewData
    deriving (Eq, Show)

data State a = State
    { time :: Unsigned 32
    , d :: a
    , dataTime :: Unsigned 32
    , step :: Step
    , changeIsSent :: Bool
    } deriving Show


-- initialState = State 0 0 0 Initial False
initialState = State
    { time = 0
    , d = 0
    , dataTime = 0
    , step = Initial
    , changeIsSent = False
    }



data Input a = Input
    { newData :: a
    , dataSent :: Bit
    , newDataMask :: a
    }



isNewData :: Eq a => a -> a -> Bool
isNewData old new =
    old /= new



updateState :: (Bits a, Eq a) => Input a -> State a -> State a
updateState (Input newData dataSent dataMask) state =
    let
        isUpdated = isNewData newData (d state)
    in
        state
            { d = newData .&. dataMask
            , time = (time state + 1)
            , dataTime =
                if changeIsSent state || isUpdated then
                    time state
                else
                    dataTime state
            , step =
                if isUpdated then
                    NewData
                else
                    Initial
            , changeIsSent =
                if isUpdated then
                    False
                else if dataSent == 1 then
                    True
                else
                    changeIsSent state
            }



output :: Eq a => Input a -> State a -> (Unsigned 32, a, Bit)
output (Input newData _ _) State {d=d, dataTime=dataTime, step=step} =
    (dataTime, d, unpack $ pack (step == NewData))



signalAnalyserT :: (Eq a, Bits a) => State a -> Input a -> (State a, (Unsigned 32, a, Bit))
signalAnalyserT state input =
    ( updateState input state
    , output input state
    )




signalAnalyser =
    mealy signalAnalyserT initialState




{-# ANN topEntity
  (Synthesize
    { t_name   = "SignalAnalyser"
    , t_inputs = [ PortName "clk"
                 , PortName "rst"
                 , PortProduct ""
                     [ PortName "data_in"
                     , PortName "data_sent"
                     , PortName "channel_mask"
                     ]
                 ]
    , t_output = PortProduct ""
        [ PortName "data_time"
        , PortName "data_out"
        , PortName "new_data"
        ]
    }) #-}
topEntity
  :: Clock System Source
  -> Reset System Asynchronous
  -> Signal System (Input (Unsigned 8))
  -> Signal System (Unsigned 32, Unsigned 8, Bit)
topEntity = exposeClockReset signalAnalyser


