module Spi where

import Clash.Prelude
import Clash.Explicit.Testbench



data State
    = Start
    | ClkRising
    | ClkUp
    | ClkDown
    deriving Show



spiT (state, d) (clk, input) =
    case state of
        Start ->
            case clk of
                1 -> ((ClkRising, d), (d, low))
                _ -> ((Start, d), (d, low))
        ClkDown ->
            case clk of
                1 -> ((ClkRising, d), (d, low))
                _ -> ((Start, d), (d, low))
        ClkRising ->
            let
                toAdd = case input of
                    1 -> 1
                    0 -> 0

                newD = (shift d 1) + toAdd
            in
                ((ClkUp, newD), (newD, low))
        ClkUp ->
            case clk of
                1 -> ((ClkDown, d), (d, low))
                _ -> ((ClkUp, d), (d, low))


-- maskedCounter :: HiddenClockReset domain gated synchronous =>
--     Signal domain a -> Signal domain a
-- spi :: Signal System (Bit, Bit) -> Signal System a
spi =
    mealy spiT (Start, 0)


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


