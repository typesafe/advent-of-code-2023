const std = @import("std");
const testing = std.testing;
const Input = @import("Input.zig");

test "day 8, part 1" {
    var lines = try Input.readLines("src/day8.txt", testing.allocator);
    defer lines.deinit() catch unreachable;

    const instructions = lines.next().?;
    _ = lines.next();

    var nodes = std.StringHashMap([2][3]u8).init(testing.allocator);
    defer nodes.deinit();

    while (lines.next()) |line| {
        try nodes.put(
            line[0..3],
            .{ .{ line[7], line[8], line[9] }, .{ line[12], line[13], line[14] } },
        );
    }

    var steps: usize = 0;
    var currentNode: []const u8 = "AAA";

    loop: while (true) {
        for (instructions) |instruction| {
            switch (instruction) {
                'L' => currentNode = &nodes.get(currentNode).?[0],
                'R' => currentNode = &nodes.get(currentNode).?[1],
                else => unreachable,
            }
            steps += 1;
            if (std.mem.eql(u8, "ZZZ", currentNode)) {
                break :loop;
            }
        }
    }

    std.debug.print("solution: {}\n", .{steps});
    try testing.expect(steps == 15871);
}
