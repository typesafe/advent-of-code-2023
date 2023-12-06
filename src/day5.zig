const std = @import("std");
const testing = std.testing;
const Input = @import("Input.zig");

test "day 5, part 1" {
    const almanac = try Input.readFile("src/day5.txt", testing.allocator);
    defer testing.allocator.free(almanac);

    var blocks = std.mem.splitSequence(u8, almanac, "\n\n");
    var seedIterator = std.mem.splitScalar(u8, blocks.next().?, ' ');
    _ = seedIterator.next().?; // skip header

    var maps = std.ArrayList(Map).init(testing.allocator);
    defer {
        for (maps.items) |map| {
            map.ranges.deinit();
        }
        maps.deinit();
    }

    while (blocks.next()) |map| {
        try maps.append(.{ .ranges = try getMapRanges(map, testing.allocator) });
    }

    var lowestLocation: isize = 0;

    const seeds = Input.parseInts(seedIterator, 20);

    for (seeds) |seed| {
        var value = seed;

        for (maps.items) |map| {
            for (map.ranges.items) |range| {
                if (value >= range.from and value < range.to) {
                    value = value + range.increment;
                    break;
                }
            }
        }

        if (value < lowestLocation or lowestLocation == 0) {
            lowestLocation = value;
        }
    }

    std.debug.print("solution: {}\n", .{lowestLocation});
    try testing.expect(lowestLocation == 825516882);
}

test "day 5, part 2" {
    const content = try Input.readFile("src/day5.txt", testing.allocator);
    defer testing.allocator.free(content);

    var blocks = std.mem.splitSequence(u8, content, "\n\n");

    var seedIterator = std.mem.splitScalar(u8, blocks.next().?, ' ');
    _ = seedIterator.next().?; // skip header

    var maps = std.ArrayList(SliceMap).init(testing.allocator);
    defer {
        for (maps.items) |map| {
            testing.allocator.free(map.ranges);
        }
        maps.deinit();
    }

    while (blocks.next()) |map| {
        var list = try getMapRanges(map, testing.allocator);
        const slice = try list.toOwnedSlice();

        std.sort.insertion(Range, slice, {}, sortMap);

        try maps.append(.{ .ranges = slice });
    }

    var lowestLocation: isize = 0;

    while (seedIterator.next()) |s| {
        var sourceRanges = std.ArrayList([2]isize).init(testing.allocator);
        defer sourceRanges.deinit();

        const start = Input.parseInt(s);
        const count = Input.parseInt(seedIterator.next().?);

        // we start with range in the list, as we map it,
        // it will be split into multiple ranges
        try sourceRanges.append(.{ start, start + count - 1 });

        for (maps.items) |map| {
            const currentSourceRanges = try sourceRanges.toOwnedSlice(); // sourceRanges is now empty
            defer testing.allocator.free(currentSourceRanges);

            for (currentSourceRanges) |sourceRange| {
                var offset: isize = sourceRange[0];

                for (map.ranges) |range| {
                    if (range.to < offset or range.from > sourceRange[1]) {
                        continue;
                    }

                    if (range.from > offset) {
                        try sourceRanges.append(.{
                            offset,
                            range.from - 1,
                        });
                        offset = range.from;
                    }

                    try sourceRanges.append(
                        .{
                            @max(offset, range.from) + range.increment,
                            @min(sourceRange[1], range.to - 1) + range.increment,
                        },
                    );

                    offset = @min(sourceRange[1], range.to);
                }

                if (offset < sourceRange[1]) {
                    try sourceRanges.append(.{ offset, sourceRange[1] });
                }
            }
        }

        for (sourceRanges.items) |sourceRange| {
            if (sourceRange[0] < lowestLocation or lowestLocation == 0) {
                lowestLocation = sourceRange[0];
            }
        }
    }

    std.debug.print("solution: {}\n", .{lowestLocation});
    try testing.expect(lowestLocation == 136096660);
}

const SliceMap = struct { ranges: []Range };
const Map = struct { ranges: std.ArrayList(Range) };
const Range = struct { from: isize, to: isize, increment: isize };

fn sortMap(_: void, a: Range, b: Range) bool {
    return a.from < b.from;
}

fn getMapRanges(map: []const u8, allocator: std.mem.Allocator) !std.ArrayList(Range) {
    var it = std.mem.splitScalar(u8, map, '\n');
    const header = it.next().?; // skip header
    _ = header;

    var list = std.ArrayList(Range).init(allocator);
    while (it.next()) |range| {
        const values = Input.parseInts(std.mem.splitScalar(u8, range, ' '), 3);

        try list.append(.{
            .from = values[1],
            .to = values[1] + values[2],
            .increment = values[0] - values[1],
        });
    }

    return list;
}
