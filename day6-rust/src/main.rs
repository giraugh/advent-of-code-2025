use std::{env::args, fs::read_to_string, str::FromStr};

use itertools::Itertools;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Op {
    Sum,
    Product,
}

impl FromStr for Op {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s.trim() {
            "*" => Ok(Self::Product),
            "+" => Ok(Self::Sum),
            _ => Err("No such operator".to_owned()),
        }
    }
}

struct Worksheet {
    ops: Box<[Op]>,
    problems: String,
}

impl FromStr for Worksheet {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut lines = s.lines();
        let ops: Box<[Op]> = lines
            .next_back()
            .ok_or_else(|| "Expected at least one line".to_owned())?
            .split_whitespace()
            .flat_map(FromStr::from_str)
            .collect();
        Ok(Worksheet {
            ops,
            problems: lines.map(ToString::to_string).join("\n"),
        })
    }
}

impl Worksheet {
    fn solve(&self) -> usize {
        let table = self.problems_table().unwrap();
        let mut sum = 0;
        for x in 0..self.ops.len() {
            let op = self.ops[x];
            let mut result: Option<usize> = None;
            for y in 0..self.problems.len() {
                let operand = table[y][x];
                match result.as_mut() {
                    None => {
                        result = Some(operand);
                    }
                    Some(r) => match op {
                        Op::Sum => {
                            *r += operand;
                        }
                        Op::Product => {
                            *r *= operand;
                        }
                    },
                }
            }
            sum += result.unwrap();
        }
        sum
    }

    fn problems_table(&self) -> Result<Box<[Box<[usize]>]>, String> {
        self.problems
            .lines()
            .map(|line| {
                line.split_whitespace()
                    .map(|d| d.parse::<usize>().map_err(|_| "Invalid number".to_owned()))
                    .collect::<Result<Box<_>, String>>()
            })
            .collect::<Result<Box<_>, String>>()
    }

    fn solve2(&self) -> u64 {
        // How wide is the file?
        let bytes = self
            .problems
            .as_bytes()
            .iter()
            .copied()
            .filter(|&d| d != b'\n')
            .collect::<Box<[_]>>();
        let width = self.problems.lines().next().unwrap().len();
        let height = bytes.len() / width;
        dbg!(width, height);
        debug_assert_eq!(width * height, bytes.len());

        let mut tot: u64 = 0;
        let mut col_ind = self.ops.len() - 1;
        let mut col_acc: u64 = match self.ops[col_ind] {
            Op::Sum => 0,
            Op::Product => 1,
        };

        for x in (0..width).rev() {
            let mut pow = 0;
            let mut acc = 0;
            for y in (0..height).rev() {
                let c = bytes[y * width + x];
                match c {
                    s if s.is_ascii_whitespace() => {
                        continue;
                    }
                    d if d.is_ascii_digit() => {
                        let v = d - b'0';
                        acc += 10_u32.pow(pow) * (v as u32);
                        pow += 1;
                    }
                    _ => panic!("Unknown c"),
                }
            }

            // Update the column value
            if pow > 0 {
                match self.ops[col_ind] {
                    Op::Sum => col_acc += acc as u64,
                    Op::Product => col_acc *= acc as u64,
                }
            }

            // Saw nothing?
            if pow == 0 || x == 0 {
                eprintln!("Tot for {col_ind} was {col_acc}");
                // Update the total
                tot += col_acc;

                // Update the col index
                col_ind = col_ind.saturating_sub(1);

                // Reset the column accumulator
                col_acc = match self.ops[col_ind] {
                    Op::Sum => 0,
                    Op::Product => 1,
                };
            }
        }

        tot
    }
}

fn input() -> Worksheet {
    let input_path = args().nth(1).expect("Expected input path");
    let input_text = read_to_string(input_path).unwrap();

    // ig easiest is to just put them in a table
    // then put the bottom row in a seperate structure
    Worksheet::from_str(&input_text).unwrap()
}

fn main() {
    let worksheet = input();
    // let p1 = worksheet.solve();
    // dbg!(p1);

    let p2 = worksheet.solve2();
    dbg!(p2);
}
