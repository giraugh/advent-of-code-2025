# Read the input file
input_path = ARGV[0]
input_content = File.read(input_path)

# Then split into ranges and "available" ids
ranges, ids = input_content.split("\n\n")
ranges = ranges.split("\n")
ids = ids.split("\n")

# Parse the ranges
# I know what you want from me here Eric but I *AM* gonna try to bruteforce it first
ids = ids.map { |id| id.to_i }
ranges = ranges.map { |range|
  a, b = range.split('-')
  [a.to_i, b.to_i]
}

# For each id, does it fit into a range?
# Part 1
puts "p1=%d" % ids.filter { |id|
  ranges.any? { |a, b| a <= id and b >= id  }
}.size

# Part 2
# Okay fine...
#  We need to normalise our ranges so they are non-overlapping
#  To do so we'll create a new array and then slowly add each range to it, checking for overlaps as we go
#  there's prob a better datastructure for this right? Like something with sorting built in?
sum = 0
ranges_n = []
ranges.each { |range|
  # Remove any we fully contain
  ranges_n = ranges_n.reject { |a, b| range[0] <= a and range[1] >= b }

  # Is there a range in ranges_n where either endpoint of this range would be contained?
  left_intersecting = ranges_n.filter_map { |a, b| b if range[0] >= a and range[0] <= b }
  right_intersecting = ranges_n.filter_map { |a, b| a if range[1] >= a and range[1] <= b }

  # Adjust the range so its entirely novel...?
  range[0] = left_intersecting.min + 1 unless left_intersecting.empty?
  range[1] = right_intersecting.max - 1 unless right_intersecting.empty?

  if range[0] <= range[1] then
    ranges_n.append range
  end
}

puts "p2=%d" % sum
