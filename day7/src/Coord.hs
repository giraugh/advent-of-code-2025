module Coord (Coord (..), right, left, down) where

-- Implementing a basic vec2 type here, stealing a lot of ideas/code from https://hackage.haskell.org/package/yx-0.0.4.3/docs/src/Data.Geometry.YX.html
data Coord = Coord {x :: Int, y :: Int} deriving (Eq, Ord, Show)

-- for defining unary ops like negation
lift1 :: (Int -> Int) -> Coord -> Coord
lift1 f (Coord x1 y1) = Coord (f x1) (f y1)

-- for defining binary operations which match up the x-y values
lift2 :: (Int -> Int -> Int) -> Coord -> Coord -> Coord
lift2 f (Coord x1 y1) (Coord x2 y2) = Coord (f x1 x2) (f y1 y2)

left :: Coord -> Coord
left (Coord cx cy) = Coord (cx - 1) cy

right :: Coord -> Coord
right (Coord cx cy) = Coord (cx + 1) cy

down :: Coord -> Coord
down (Coord cx cy) = Coord cx (cy + 1)

instance Num Coord where
  (+) = lift2 (+)
  (*) = lift2 (*)
  abs = lift1 abs
  signum = lift1 signum
  negate = lift1 negate
  fromInteger i = Coord i' i' where i' = fromInteger i
