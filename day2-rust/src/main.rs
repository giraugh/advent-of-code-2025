use std::{fs::read_to_string, ops::RangeInclusive};

fn main() {
    let input = read_to_string("./input.txt").unwrap();
    dbg!(solve_p1(&input));
    dbg!(solve_p2(&input));
}

fn ranges(input: &str) -> impl Iterator<Item = RangeInclusive<usize>> {
    input.lines().next().unwrap().split(",").map(|range| {
        let (start, end) = range.split_once("-").unwrap();
        let (start, end) = (
            start.parse::<usize>().unwrap(),
            end.parse::<usize>().unwrap(),
        );
        start..=end
    })
}

fn solve_p1(input: &str) -> usize {
    let invalid = ranges(input).flatten().filter(|id| id_is_invalid(*id));
    invalid.sum()
}

fn solve_p2(input: &str) -> usize {
    let invalid = ranges(input).flatten().filter(|id| id_is_invalid_2(*id));
    invalid.sum()
}

fn id_is_invalid(id: usize) -> bool {
    let id = id.to_string().chars().collect::<Vec<_>>();

    if id.len() % 2 != 0 {
        return false;
    }

    let blocks = &mut id[..].chunks(id.len() / 2);
    let val = blocks.next().unwrap();
    if blocks.all(|b| b == val) {
        return true;
    }

    false
}

fn id_is_invalid_2(id: usize) -> bool {
    let id = id.to_string().chars().collect::<Vec<_>>();

    // For each block size, does it fully repeat?
    for s in 1..=id.len() / 2 {
        let blocks = &mut id[..].chunks(s);
        let val = blocks.next().unwrap();
        if blocks.all(|b| b == val) {
            return true;
        }
    }

    false
}

#[test]
fn test_sample() {
    let sample = read_to_string("./sample.txt").unwrap();
    assert_eq!(solve_p1(&sample), 1227775554);
}

#[test]
fn test_sample_2() {
    let sample = read_to_string("./sample.txt").unwrap();
    assert_eq!(solve_p2(&sample), 4174379265);
}

#[test]
fn test_invalid() {
    assert!(id_is_invalid(222222));
    assert!(id_is_invalid(1010));
    assert!(!id_is_invalid(1234));
}

#[test]
fn test_invalid_2() {
    assert!(id_is_invalid_2(111));
    assert!(id_is_invalid_2(1188511885));
    assert!(id_is_invalid_2(446446));
    assert!(id_is_invalid_2(565656));
    assert!(!id_is_invalid_2(1234));
}
