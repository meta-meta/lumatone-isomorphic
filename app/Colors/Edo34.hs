module Colors.Edo34 where

import           Data.Map (Map)
import qualified Data.Map   as M
import           Data.Set (Set)
import qualified Data.Set   as S

import Colors.Simple
import Types


-- | Four non-overlapping chains of 7 notes separated by 3:2.
theMap :: [(MidiNote, Color)]
theMap = octaveSeparators ++ chainsOfFifths where

  octaveSeparators = [
    {- The chains of fifth leave six notes uncolored:
    [4,9,14,19,24,29].
    This group colors half of them white,
    to serve as octave separators.
    The choice is a little arbitrary,
    but works out well for `go 34 7 3 0 0` -}
    (14, color_white),
    (19, color_white),
    (24, color_white) ]

  chainsOfFifths = [
    ( 0, color_r),
    (20, color_r),
    ( 6, color_r),
    (26, color_r),
    (12, color_r),
    (32, color_r),
    (18, color_r),

    ( 5, color_g),
    (25, color_g),
    (11, color_g),
    (31, color_g),
    (17, color_g),
    ( 3, color_g),
    (23, color_g),

    (10, color_b),
    (30, color_b),
    (16, color_b),
    ( 2, color_b),
    (22, color_b),
    ( 8, color_b),
    (28, color_b),

    (15, color_rg),
    ( 1, color_rg),
    (21, color_rg),
    ( 7, color_rg),
    (27, color_rg),
    (13, color_rg),
    (33, color_rg)]
