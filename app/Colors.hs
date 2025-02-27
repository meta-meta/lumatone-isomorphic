module Colors where

import           Data.Map (Map)
import qualified Data.Map   as M
import           Data.Set (Set)
import qualified Data.Set   as S

import Colors.Simple
import Colors.Edo34
import Colors.Edo46 {- | PITFALL: For at least non-Bosanquet layouts
  (and maybe even some Bosanquet ones --
  I only remember having tested with 41-edo and 53-edo)
  the function `chains_of_fifths` turns out not to be very useful.
  It defines chains of fifths well enough,
  but nothing guarantees that the white notes that start each chain
  form a pattern that repeats recognizably every octave,
  the way it does for the Bosanquet layouts I've tested.
  For this reason I've defined a color map for 46-edo "by hand" (-ish).
  That's probably the way to go with other edos,
  if the default colors are confusing.
  -}
import Types


-- * Mapping notes to colors

-- | The Edo determines the color map used.
--
-- PITFALL: If it's not an Edo I've made a color map for,
-- I just give it the 50-edo color map,
-- since that's got the maximum possible number of note-color
-- pairs (49, given that there are only 7 colors and 7 notes
-- per color) and is empty almost nowhere.
color :: Edo -> MidiNote -> Color
color edo note =
  let color_map :: Map MidiNote Color
      color_map = maybe (M.fromList colors_for_50_edo) id $
                  M.lookup edo color_maps
  in maybe default_color id $
     M.lookup note color_map

-- | This assigns colors to EDO values.
-- Not every EDO value needs to have a color assigned,
-- and they do not need to be defined in order.
--
-- These colors work out nicely for Bosanquet 41-edo.
-- For some other edo and/or layout, they might not.
color_maps :: Map Edo (Map MidiNote Color)
color_maps = M.map M.fromList $ M.fromList $ [
  (31, colors_for_31_edo),
  (41, colors_for_41_edo),
  (50, colors_for_50_edo),
  (53, colors_for_53_edo),
  (58, colors_for_58_edo),

  -- See the comment on the corresponding import statements
  -- for why the lines below differ from the lines above.
  (34, Colors.Edo34.theMap),
  (46, Colors.Edo46.theMap)
  ]

colors_for_31_edo :: [(MidiNote, Color)]
colors_for_31_edo = chains_to_note_colors $
                    chains_of_fifths 31 18 2 4

colors_for_41_edo :: [(MidiNote, Color)]
colors_for_41_edo = chains_to_note_colors $
                    chains_of_fifths 41 24 4 5

colors_for_50_edo :: [(MidiNote, Color)]
colors_for_50_edo = chains_to_note_colors $
                    chains_of_fifths 50 29 3 7

colors_for_53_edo :: [(MidiNote, Color)]
colors_for_53_edo = chains_to_note_colors $
                    chains_of_fifths 53 31 5 7

colors_for_58_edo :: [(MidiNote, Color)]
colors_for_58_edo = chains_to_note_colors $
                    chains_of_fifths 58 34 3 7


-- * Note chains

type NoteChains =
  [ (EdoNote,
     (Int, -- ^ identifies the chain the note is in
      Int -- ^ identifies the note's position in the chain
     ) ) ]

-- | These can actually be chains of anything,
-- not just fifths.
--
-- PITFALL: Determining the arguments to use for
-- `chains_of_fifths` turned out to be easier than I expected,
-- if the edo has a bosanquet layout.
-- The interval to chain is whatever a fifth is in that edo --
-- 24 in 41-edo, for instance.
-- The distance between chains can (I believe) always be
-- set to equal the diagonal distance in the bosanquet layout.
-- For instance, in 31-edo it's 2 halfsteps, because
-- 31-edo's bosanquet layout uses unit vectors 5\31 and 3\31.
-- Doing that seems to perfectly avoid collisions,
-- such that the last argument, the number of chains,
-- can be equal to `div edo 7`.
chains_of_fifths ::
  Edo ->
  EdoNote -> -- ^ the interval to chain
  EdoNote -> -- ^ the distance between chains
  Int -> -- ^ The number of chains. Currently maxes out at 7,
         -- because that's the number of non-black colors
         -- defined in `colors`. Could easily be more.
  NoteChains
chains_of_fifths edo perfect_fifth jump nChains =
  [ (mod (jump * i + j * perfect_fifth) edo,
     (i, j))
  | i <- [0..nChains-1],
    j <- [0..6] -- To resemble the white keys, i takes 7 values.
                -- If the groups are to have some other size,
                -- this should be a variable argument.
  ]

-- | This turns out not even to be necessary if the edo
-- has a bosanquet layout, although it's a reassuring check.
chains_do_not_overlap :: NoteChains -> Bool
chains_do_not_overlap chains =
  let notes = map fst chains
  in length (S.toList $ S.fromList notes)
     == length notes

chains_to_note_colors :: NoteChains -> [(MidiNote, Color)]
chains_to_note_colors = map f where
  f :: (EdoNote, (Int,Int)) -> (MidiNote, Color)
  f (note, (group, position)) =
    (note, if position == 0
           then color_white
           else maybe color_black id $
                M.lookup group colors )
