{-# LANGUAGE LambdaCase #-}

module Main where

import Control.Arrow ((&&&))
import Control.Monad.State
import Coord (Coord (..))
import qualified Coord
import Data.Set (Set, empty, insert, member, notMember, union)
import qualified Data.Set

-- Just output the two solutions as a tuple
main :: IO ()
main = interact $ show . (solve1 &&& solve2) . parse

-------- -------- -------- -------- -------- --------
-- Parsing text into our "manifold" type
-------- -------- -------- -------- -------- --------

data Manifold = Manifold {splitters :: Set Coord, start :: Coord} deriving (Show)

maxY :: Manifold -> Int
maxY = maximum . Data.Set.map y . splitters

parse :: String -> Manifold
parse s = buildManifold initial s (Coord 0 0)
  where
    initial = Manifold {splitters = empty, start = Coord 0 0}

    buildManifold :: Manifold -> String -> Coord -> Manifold
    buildManifold m [] _ = m
    buildManifold m (c : cs) pos = case c of
      '\n' -> buildManifold m cs $ Coord 0 (1 + y pos)
      '.' -> buildManifold m cs (Coord.right pos)
      '^' -> buildManifold (m {splitters = insert pos (splitters m)}) cs $ Coord.right pos
      'S' -> buildManifold (m {start = pos}) cs $ Coord.right pos
      _ -> error $ "Unexpected char" ++ [c]

-------- -------- --------
-- Part 1 Solution
-------- -------- --------

solve1 :: Manifold -> Int
solve1 m = countSplits [start m] empty 0
  where
    -- Is there a splitter at this given coordinate?
    isSplitter :: Coord -> Bool
    isSplitter p = member p $ splitters m

    -- Recursively count the number of splits possible
    -- countSplits :: active historic acc -> result
    countSplits :: [Coord] -> Set Coord -> Int -> Int
    countSplits [] _ acc = acc
    countSplits (t : ts) pt acc
      | Coord.y d > maxY m = countSplits ts pt acc -- We would go off the screen
      | isSplitter d = countSplits ts' pt' acc' -- We would hit a splitter
      | otherwise = countSplits (ts ++ [d]) (Data.Set.insert t pt) acc -- We would hit nothing
      where
        d = Coord.down t
        l = Coord.left d
        r = Coord.right d

        -- If we do split, we need to figure out which positions dont have historic tachyons in them
        ps = [l | l `notMember` pt] ++ [r | r `notMember` pt]
        ts' = ts ++ ps
        pt' = Data.Set.fromList ps `union` pt

        -- Would we even split at all?
        acc' = acc + if null ps then 0 else 1

-------- -------- --------
-- Part 2 Solution
-------- -------- --------

-- Association list style cache for memoizing our p2 solution
type Cache = [(Coord, Int)]

-- Kind of like part 1 but whenever we split, count all the splits that could happen after that
-- Using a dynamic programming approach, just memoize the results
-- (Im using a state monad for it and its a tiny bit of a nightmare)
solve2 :: Manifold -> Int
solve2 m = evalState (countTimelines' (start m)) []
  where
    -- Is there a splitter at this given coordinate?
    isSplitter :: Coord -> Bool
    isSplitter p = member p $ splitters m

    -- Check the cache, use the value if present
    -- if not present, compute the value and store that before returning
    countTimelines' :: Coord -> State Cache Int
    countTimelines' t =
      gets (lookup t) >>= \case
        Just v -> pure v
        Nothing -> countTimelines t >>= \v -> modify ((t, v) :) >> pure v

    -- Compute the number of timelines after a given position
    -- (Under the state monad storing the memoize cache)
    -- (Recurses using the cached version)
    countTimelines :: Coord -> State Cache Int
    countTimelines t
      | Coord.y d > maxY m = pure 1 -- would go off the screen
      | isSplitter d = (+) <$> countTimelines' l <*> countTimelines' r -- would hit a splitter
      | otherwise = countTimelines d -- would hit nothing
      where
        d = Coord.down t
        l = Coord.left d
        r = Coord.right d
