use itertools::Itertools;
use std::{
    collections::{BTreeMap, HashMap},
    env::args,
    fs::read_to_string,
    str::FromStr,
};

/// X, Y, Z
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
struct Point3(usize, usize, usize);

impl Point3 {
    /// We compute the squared distance since it still sorts the same
    /// and saves us dealing w/ floating points
    /// plus its faster!!
    pub fn dist_squared_to(&self, other: &Self) -> usize {
        let (x1, y1, z1) = (self.0 as isize, self.1 as isize, self.2 as isize);
        let (x2, y2, z2) = (other.0 as isize, other.1 as isize, other.2 as isize);
        ((x2 - x1).pow(2) + (y2 - y1).pow(2) + (z2 - z1).pow(2)) as usize
    }
}

impl FromStr for Point3 {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let (x, rest) = s
            .split_once(",")
            .ok_or_else(|| "No first comma".to_owned())?;
        let (y, z) = rest
            .split_once(",")
            .ok_or_else(|| "No second comma".to_owned())?;
        let x = x.parse().map_err(|_| "Malformed x".to_owned())?;
        let y = y.parse().map_err(|_| "Malformed y".to_owned())?;
        let z = z.parse().map_err(|_| "Malformed z".to_owned())?;
        Ok(Point3(x, y, z))
    }
}

fn get_input() -> Box<[Point3]> {
    let input_path = args().nth(1).expect("Expected input path");
    let input_text = read_to_string(input_path).unwrap();
    input_text
        .lines()
        .map(FromStr::from_str)
        .collect::<Result<Box<[Point3]>, _>>()
        .unwrap()
}

fn main() {
    dbg!(part1());
    dbg!(part2());
}

fn part1() {
    dbg!(network(Some(1000)));
}

fn part2() {
    dbg!(network(None));
}

fn network(max_iters: Option<usize>) -> usize {
    let junction_boxes = get_input();

    let mut circuits = {
        let mut next_id = 0;
        junction_boxes
            .iter()
            .map(|b| {
                let v = (*b, next_id);
                next_id += 1;
                v
            })
            .collect::<HashMap<Point3, usize>>()
    };

    // Find the closest pair of points
    let pairs = junction_boxes
        .iter()
        .tuple_combinations::<(_, _)>()
        .filter(|(a, b)| a != b)
        .sorted_by_key(|(a, b)| a.dist_squared_to(b))
        .take(max_iters.unwrap_or(usize::MAX));

    for (point1, point2) in pairs {
        match (circuits.get(point1).cloned(), circuits.get(point2).cloned()) {
            (None, None) => unreachable!(),
            (None, Some(c)) => {
                // Add 1 to circuit
                circuits.insert(*point1, c);
            }
            (Some(c), None) => {
                // Add 2
                circuits.insert(*point2, c);
            }
            (Some(a), Some(b)) => {
                // Set all of A to B
                circuits
                    .iter_mut()
                    .filter(|(_, c)| **c == a)
                    .for_each(|(_v, c)| {
                        *c = b;
                    });

                if circuits.values().unique().count() == 1 {
                    dbg!(point1.0 * point2.0);

                    break;
                }
            }
        }
    }

    // Analyse the circuits to group by id
    let mut sizes = BTreeMap::<usize, usize>::new();
    for (_, circuit_id) in circuits {
        sizes.entry(circuit_id).and_modify(|x| *x += 1).or_insert(1);
    }

    // hmm not quite right
    sizes
        .into_values()
        .sorted()
        .rev()
        .take(3)
        .reduce(|a, b| a * b)
        .unwrap()
}
