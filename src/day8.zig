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

test "day 8, part 2" {
    var lines = try Input.readLines("src/day8.txt", testing.allocator);
    defer lines.deinit() catch unreachable;

    const instructions = lines.next().?;
    _ = lines.next();

    var nodes = std.StringHashMap([2][3]u8).init(testing.allocator);
    defer nodes.deinit();
    var startingNodes = std.ArrayList([3]u8).init(testing.allocator);
    defer startingNodes.deinit();

    while (lines.next()) |line| {
        try nodes.put(line[0..3], .{ .{ line[7], line[8], line[9] }, .{ line[12], line[13], line[14] } });
        if (line[2] == 'A') {
            try startingNodes.append(.{ line[0], line[1], line[2] });
        }
    }

    var steps: usize = 0;
    var currentLcm: u128 = 0;

    loop: while (true) {
        for (instructions) |instruction| {
            steps += 1;

            var i: usize = 0;
            while (true) {
                const from = startingNodes.items[i];
                const to = nodes.get(&from).?[if (instruction == 'L') 0 else 1];
                startingNodes.items[i] = to;

                if (to[2] == 'Z') {
                    _ = startingNodes.orderedRemove(i);

                    if (currentLcm == 0) {
                        currentLcm = @as(u128, steps);
                    } else {
                        currentLcm = lcm(@as(u128, steps), currentLcm);
                    }
                } else {
                    i += 1;
                }

                if (startingNodes.items.len == 0) {
                    break :loop;
                } else if (i >= startingNodes.items.len) {
                    break;
                }
            }
        }
    }

    std.debug.print("solution: {}\n", .{currentLcm});
    try testing.expect(currentLcm == 11283670395017);
}

fn lcm(large: u128, small: u128) u128 {
    return (large * small) / gcd(large, small);
}

test "lcm" {
    try testing.expect(lcm(48, 18) == 144);
}

fn gcd(a: u128, b: u128) u128 {
    var s = if (b > a) a else b;
    var l = if (a > b) a else b;

    while (s != 0) {
        const t = s;
        s = l % s;
        l = t;
    }

    return l;
}

test "gcd" {
    try testing.expect(gcd(48, 18) == 6);
}
