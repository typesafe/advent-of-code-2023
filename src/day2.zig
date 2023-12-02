const std = @import("std");
const testing = std.testing;
const Input = @import("Input.zig");

test "day 2, part 1" {
    var it = try Input.readLines("src/day2.txt", testing.allocator);
    defer it.deinit() catch unreachable;

    var sumOfGameIds: u32 = 0;

    while (it.next()) |line| {
        var idAndSets = std.mem.splitScalar(u8, line, ':');
        const identifier = idAndSets.next().?;
        var sets = idAndSets.next().?;

        var setsComply = true;
        var setIterator = std.mem.splitScalar(u8, sets, ';');

        while (setIterator.next()) |set| {
            // " b blue, gg green, r red" // or any other order, note the leading space
            var rgb = std.mem.zeroes([3]u8);
            var colorAndCount = std.mem.splitScalar(u8, set[1..set.len], ' ');
            while (colorAndCount.next()) |count| {
                const v = try std.fmt.parseInt(u8, count, 10);
                const c = colorAndCount.next().?[0];
                switch (c) {
                    'r' => rgb[0] = v,
                    'g' => rgb[1] = v,
                    'b' => rgb[2] = v,
                    else => unreachable,
                }
            }

            if (rgb[0] > 12 or rgb[1] > 13 or rgb[2] > 14) {
                setsComply = false;
                break;
            }
        }

        if (setsComply) {
            sumOfGameIds += try std.fmt.parseInt(u32, identifier[5..identifier.len], 10);
        }
    }

    std.debug.print("solution: {}\n", .{sumOfGameIds});
}
