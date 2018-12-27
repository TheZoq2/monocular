module ControlMessageDecoder where

import Clash.Prelude
import Clash.Explicit.Testbench

data Step
    = Waiting
    | ReceivedStart
    | ReceivingMask
    | ReceivedMask (Unsigned 8)


data State = State
    { step :: Step
    , channelMask :: Unsigned 8
    }

initialState :: State
initialState =
    State { channelMask = 0
          , step = Waiting
          }



data Input = Input
    { spiData :: Unsigned 8
    , newData :: Bit
    }


data Output = Output
    { outChannelMask :: Unsigned 8
    }


updateState :: Input -> State -> State
updateState input state =
    state

output :: State -> Output
output state =
    Output { outChannelMask = channelMask state }


controlMessageDecoderT :: State -> Input -> (State, Output)
controlMessageDecoderT state input =
    ( updateState input state
    , output state
    )




controlMessageDecoder =
    mealy controlMessageDecoderT initialState


{-# ANN topEntity
  (Synthesize
    { t_name   = "ControlMessageDecoder"
    , t_inputs = [ PortName "clk"
                 , PortName "rst"
                 , PortProduct ""
                    [ PortName "spi_byte"
                    ]
                 ]
    , t_output = PortName "channel_mask"
    }) #-}
topEntity
  :: Clock System Source
  -> Reset System Asynchronous
  -> Signal System Input
  -> Signal System Output
topEntity = exposeClockReset controlMessageDecoder
