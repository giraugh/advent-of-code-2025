module Coord (Coord (..), right, left, down) where

-- Implementing a basic vec2 type here, with methods for getting its neighbours
data Coord = Coord {x :: Int, y :: Int} deriving (Eq, Ord, Show)

left :: Coord -> Coord
left (Coord cx cy) = Coord (cx - 1) cy

right :: Coord -> Coord
right (Coord cx cy) = Coord (cx + 1) cy

down :: Coord -> Coord
down (Coord cx cy) = Coord cx (cy + 1)
