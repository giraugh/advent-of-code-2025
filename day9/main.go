package main

import (
	"cmp"
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"
)

type Pos struct {
	x int
	y int
}

type Rect struct {
	start Pos
	end   Pos
}

func IAbs(x int) int {
	if x < 0 {
		return -x
	} else {
		return x
	}
}

func ISignum(x int) int {
	if x == 0 {
		return 0
	}
	if x > 0 {
		return 1
	} else {
		return -1
	}
}

func DotProd(pos1 Pos, pos2 Pos) int {
	return pos1.x*pos2.x + pos1.y*pos2.y
}

func AreaBetween(pos1 Pos, pos2 Pos) int {
	dx := pos2.x - pos1.x
	dy := pos2.y - pos1.y
	return (IAbs(dx) + 1) * (IAbs(dy) + 1)
}

func DistBetween(pos1 Pos, pos2 Pos) int {
	if pos1.x == pos2.x {
		return IAbs(pos2.y - pos1.y)
	}

	if pos1.y == pos2.y {
		return IAbs(pos2.x - pos1.x)
	}

	panic("Points are not on a shared line")
}

func PointBetween(pos1 Pos, pos2 Pos) Pos {
	return Pos{
		x: (pos1.x + pos2.x) / 2,
		y: (pos1.y + pos2.y) / 2,
	}
}

func RectCenter(rect Rect) Pos {
	return PointBetween(rect.start, rect.end)
}

// Does not include edges
func PointInRect(pos Pos, rect Rect) bool {
	min_x := min(rect.start.x, rect.end.x)
	max_x := max(rect.start.x, rect.end.x)
	min_y := min(rect.start.y, rect.end.y)
	max_y := max(rect.start.y, rect.end.y)

	return pos.x > min_x &&
		pos.x < max_x &&
		pos.y > min_y &&
		pos.y < max_y
}

func PointOnRectEdge(pos Pos, rect Rect) bool {
	in_x := (pos.x >= rect.start.x && pos.y <= rect.end.x)
	in_y := (pos.y >= rect.start.y && pos.y <= rect.end.y)

	return ((pos.x == rect.start.x || pos.x == rect.end.x) && in_y) ||
		((pos.y == rect.start.y || pos.y == rect.end.y) && in_x)
}

func get_input() []Pos {
	// Read the input
	input_path := os.Args[1]
	input_contents, err := os.ReadFile(input_path)
	if err != nil {
		panic(err)
	}

	// Parse as a list of positions
	positions := []Pos{}
	for line_n := range strings.Lines(string(input_contents)) {
		line := strings.TrimSpace(line_n)
		xs, ys, found := strings.Cut(line, ",")
		if !found {
			panic("no , on line")
		}

		x, e := strconv.Atoi(xs)
		if e != nil {
			panic("bad x")
		}

		y, e := strconv.Atoi(ys)
		if e != nil {
			fmt.Printf("'%s'", ys)
			panic("bad y")
		}

		positions = append(positions, Pos{x, y})
	}

	return positions
}

func main() {
	positions := get_input()

	type RectAndArea struct {
		rect Rect
		area int
	}

	rects := []RectAndArea{}
	max_area := 0
	for i, pos1 := range positions {
		for j, pos2 := range positions {
			// Only consider combs not perms 💇
			if i <= j {
				continue
			}

			// Compute the area
			rect := Rect{start: pos1, end: pos2}
			area := AreaBetween(pos1, pos2)
			max_area = max(max_area, area)

			// Insert into rectangles at the correct index
			rects = append(rects, RectAndArea{rect, area})
		}
	}

	// Part 1 answer
	fmt.Printf("Part 1 = %d\n", max_area)

	// Sort rects descending
	slices.SortFunc(rects, func(a RectAndArea, b RectAndArea) int {
		return -1 * cmp.Compare(a.area, b.area)
	})

	// We need to create extra positions in between other ones because some of the jumps are too big and cause incorrect results
	// so, look for any that are too long, then insert points between them
	for i, point := range positions {
		next := positions[(i+1)%len(positions)]
		dist := DistBetween(point, next)
		// kind of magic I admit
		if dist > 50_000 {
			// add a middle point
			positions = slices.Insert(positions, i, PointBetween(point, next))
		}
	}

	// Give each point a reverse normal vector (under signum) which points towards where its adjacent red squares are
	inwards_vecs := []Pos{}
	for i, point := range positions {
		previous := positions[(i+len(positions)-1)%len(positions)]
		next := positions[(i+1)%len(positions)]

		// create vecs a=prev->point and b=point->next
		// then rotate each one CC 90deg
		// the sum of those, normalized is the right dir
		// this is based on analysing the winding direction of the points manually
		a := Pos{x: point.x - previous.x, y: point.y - previous.y}
		b := Pos{x: next.x - point.x, y: next.y - point.y}

		// lets do some rotation math
		// we have expanded from a matrix this:
		// x′=xcosθ−ysinθ
		// y′=xsinθ+ycosθ
		//
		// but then our θ=90deg always
		// so sin90 = 1
		//    cos90 = 0
		// thus
		// x' = -y
		// y' = x
		inwards := Pos{x: ISignum(-a.y - b.y), y: ISignum(a.x + b.x)}
		inwards_vecs = append(inwards_vecs, inwards)
	}

	// consider any pair that has no other red spot in it? Because that would be a corner?
	for _, rect_area := range rects {
		// Is there a point in this range?
		has_point := false
		for point_i, point := range positions {
			// Ignore the end points of this rect
			if point == rect_area.rect.start || point == rect_area.rect.end {
				continue
			}

			// Is it completely inside (not on edge)
			// this is always bad
			if PointInRect(point, rect_area.rect) {
				has_point = true
				break
			}

			// Is it on the edge?
			// This is bad if its "inwards" vector points out of the rect
			if PointOnRectEdge(point, rect_area.rect) {
				iv := inwards_vecs[point_i]
				red_side := Pos{x: point.x + iv.x, y: point.y + iv.y}
				if !PointInRect(red_side, rect_area.rect) {
					fmt.Printf("Skip %+v\n", rect_area.rect)
					has_point = true
					break
				}
			}
		}

		if !has_point {
			fmt.Printf("Part 2 = %d\n", rect_area.area)
			break
		}
	}
}
