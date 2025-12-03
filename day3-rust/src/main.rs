use std::{collections::HashMap, env::args, fs::read_to_string};

#[derive(Debug)]
struct BatteryBank {
    pub batteries: Box<[u8]>,
    pub max_batteries: usize,
    pub cache: HashMap<(usize, usize), Option<usize>>,
}

impl BatteryBank {
    pub fn from_digits(digits: &str, max_batteries: usize) -> Self {
        let digits = digits
            .chars()
            .map(|c| c.to_digit(10).unwrap() as u8)
            .collect();
        BatteryBank::new(digits, max_batteries)
    }

    pub fn new(batteries: Box<[u8]>, max_batteries: usize) -> Self {
        Self {
            batteries,
            max_batteries,
            cache: Default::default(),
        }
    }
}

impl BatteryBank {
    /// c -> amount of batteries already turned on
    /// a -> first index of a battery we haven't turned on
    fn max_joltage_inner(&mut self, c: usize, a: usize) -> Option<usize> {
        // Check cache
        if let Some(max) = self.cache.get(&(c, a)) {
            return *max;
        }

        // If we have chosen everything, the contribution of this recursion is also 0
        if c == self.max_batteries {
            return Some(0);
        }

        // If we are at the end of the string, the max val is 0
        if a == self.batteries.len() {
            return None;
        }

        // We can include the current value or not
        // the key thing is that by including it we use up a battery we can turn on, so we need to track that too
        let do_turn_on = {
            let digit = self.batteries[a] as usize;
            let pow = 10_usize.pow(((self.max_batteries - 1) - c) as u32);
            let contribution = digit * pow;
            self.max_joltage_inner(c + 1, a + 1)
                .map(|sub| sub + contribution)
        };

        let dont_turn_on = { self.max_joltage_inner(c, a + 1) };

        let val = match (do_turn_on, dont_turn_on) {
            (Some(x), Some(y)) => Some(usize::max(x, y)),
            (Some(x), None) => Some(x),
            (None, Some(y)) => Some(y),
            (None, None) => None,
        };

        self.cache.insert((c, a), val);

        val
    }

    pub fn max_joltage(&mut self) -> usize {
        self.max_joltage_inner(0, 0).unwrap()
    }
}

#[test]
fn test_max_joltage_simple2() {
    let mut bank = BatteryBank::from_digits("811111111111119", 2);
    assert_eq!(bank.max_joltage(), 89);
}

fn banks(n: usize) -> Vec<BatteryBank> {
    let input_path = args().nth(1).expect("Expected input path");
    let input_text = read_to_string(input_path).unwrap();
    let lines = input_text.lines();
    lines
        .map(|line| BatteryBank::from_digits(line, n))
        .collect()
}

fn solve_part1() -> usize {
    let mut banks = banks(2);
    banks.iter_mut().map(|bank| bank.max_joltage()).sum()
}

fn solve_part2() -> usize {
    let mut banks = banks(12);
    banks.iter_mut().map(|bank| bank.max_joltage()).sum()
}

fn main() {
    dbg!(solve_part1());
    dbg!(solve_part2());
}
