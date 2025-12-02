const std = @import("std");
const info = std.log.info;

const Range = struct {
    from: usize,
    to: usize,
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // Get the input as a slice of ranges
    const ranges = try get_input(allocator);
    defer allocator.free(ranges);

    // Part 1:
    var sum: usize = 0;
    for (ranges) |range| {
        var i = range.from;
        while (i <= range.to) : (i += 1) {
            // First convert the int to a string
            var idBuf: [64]u8 = undefined;
            var id = try std.fmt.bufPrint(&idBuf, "{}", .{i});

            // Only possible for even length ids to be "invalid"
            if (id.len % 2 != 0) continue;

            // Is this an "invalid" id?
            // i.e does its two halves match?
            const first = id[0 .. id.len / 2];
            const second = id[id.len / 2 ..];
            if (std.mem.eql(u8, first, second)) {
                sum += i;
            }
        }
    }

    std.debug.print("Part 1 {d}\n", .{sum});

    // Part 2
    var sum2: usize = 0;
    for (ranges) |range| {
        var i = range.from;
        while (i <= range.to) : (i += 1) {
            // First convert the int to a string
            var idBuf: [64]u8 = undefined;
            var id = try std.fmt.bufPrint(&idBuf, "{}", .{i});

            // For any given chunk size up to half the len
            var s: usize = 1;
            while (s <= id.len / 2) : (s += 1) {
                if (id.len % s != 0) continue;

                // Scan through blocks of size s
                // if the previous block does not match the current block, then this cannot be invalid
                var all_equal = true;
                var prev = id[0..s];
                var j: usize = 1;
                while (j < id.len / s) : (j += 1) {
                    const curr = id[j * s .. (j + 1) * s];
                    if (!std.mem.eql(u8, prev, curr)) {
                        all_equal = false;
                        break;
                    }

                    prev = curr;
                }

                if (all_equal) {
                    sum2 += i;
                    break;
                }
            }
        }
    }

    std.debug.print("Part 2 {d}\n", .{sum2});
}

/// Read and parse the input of the file path provided in argv
/// requires an alloc and returns an owned slice
pub fn get_input(allocator: std.mem.Allocator) ![]Range {
    // Open the file
    const input_path = std.mem.sliceTo(std.os.argv[1], 0);
    const input_file = try std.fs.cwd().openFile(input_path, .{});
    defer input_file.close();

    // Prep reading
    var input_read_buffer: [1024]u8 = undefined;
    var read_wrapper = input_file.reader(&input_read_buffer);
    var reader = &read_wrapper.interface;

    var ranges = try std.ArrayList(Range).initCapacity(allocator, 200);
    defer ranges.deinit(allocator);

    // Read the file into the ranges vector
    while (try reader.takeDelimiter(',')) |range| {
        if (std.mem.indexOfScalar(u8, range, '-')) |i| {
            const from_s = range[0..i];
            const to_s = std.mem.trimEnd(u8, range[i + 1 ..], "\n");
            try ranges.append(allocator, Range{
                .from = try std.fmt.parseInt(usize, from_s, 10),
                .to = try std.fmt.parseInt(usize, to_s, 10),
            });
        }
    }

    return try ranges.toOwnedSlice(allocator);
}
