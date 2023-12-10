const std = @import("std");
const testing = std.testing;
const Input = @import("Input.zig");

test "day 10, part 1" {
    var aa = std.heap.ArenaAllocator.init(testing.allocator);
    defer aa.deinit();
    const allocator = aa.allocator();

    const grid = try Input.readGrid("src/day10.txt", 140, 140, testing.allocator);
    defer grid.deinit();

    var start: [2]usize = .{ 0, 0 };

    loop: for (0..140) |y| {
        for (0..140) |x| {
            const node = grid.get(x, y);
            if (node == 'S') {
                start = .{ x, y };
                std.debug.print("start: {any}\n", .{start});
                break :loop;
            }
        }
    }

    const solution = (try walkLoop(start, grid, allocator));

    std.debug.print("solution: {any}\n", .{solution.count() / 2});
    try testing.expect(solution.count() / 2 == 6886);
}

test "day 10, part 2" {
    var aa = std.heap.ArenaAllocator.init(testing.allocator);
    defer aa.deinit();
    const allocator = aa.allocator();

    const grid = try Input.readGrid("src/day10.txt", 140, 140, testing.allocator);
    defer grid.deinit();

    const start = findStart(grid);

    const nodes = (try walkLoop(start, grid, allocator));

    var nodesInside: usize = 0;

    for (0..140) |y| {
        // while going through a row, we can keep track of wether we went inside or not
        // by toggling the value on the relevant boundaries
        var inside: bool = false;

        for (0..140) |x| {
            const node = grid.get(x, y);
            const boundary = nodes.contains(.{ x, y });

            if (boundary and (node == '|' or node == 'L' or node == 'J' or node == 'S')) {
                inside = !inside;
            }

            if (inside and !boundary) {
                nodesInside += 1;
            }
        }
    }

    std.debug.print("solution: {any}\n", .{nodesInside});
    try testing.expect(nodesInside == 371);
}

fn findStart(grid: Input.Grid) [2]usize {
    for (0..140) |y| {
        for (0..140) |x| {
            const node = grid.get(x, y);
            if (node == 'S') {
                return .{ x, y };
            }
        }
    }

    unreachable;
}

fn walkLoop(start: [2]usize, grid: Input.Grid, allocator: std.mem.Allocator) !std.AutoHashMap([2]usize, void) {
    var nodes = std.AutoHashMap([2]usize, void).init(allocator);
    var current: [2]usize = start;
    var next = .{ start[0] + 1, start[1] };

    var steps: usize = 1;

    try nodes.put(current, {});

    while (true) {
        try nodes.put(next, {});
        if (std.mem.eql(usize, &next, &start)) {
            break;
        }

        if (getNeighbours(grid.get(next[0], next[1]))) |nbs| {
            for (nbs) |nb| {
                const x = @as(isize, @intCast(next[0])) + nb[0];
                const y = @as(isize, @intCast(next[1])) + nb[1];
                if (x >= 0 and x < 140 and y >= 0 and y < 140) {
                    const can = .{ @as(usize, @intCast(@as(isize, x))), @as(usize, @intCast(y)) };
                    if (!std.mem.eql(usize, &current, &can)) {
                        current = next;
                        next = can;
                        steps += 1;
                        break;
                    }
                }
            }
        }

        if (std.mem.eql(usize, &current, &start)) {
            break;
        }
    }

    return nodes;
}

fn getNeighbours(s: u8) ?[2][2]isize {
    return switch (s) {
        '|' => .{ .{ 0, -1 }, .{ 0, 1 } },
        '-' => .{ .{ -1, 0 }, .{ 1, 0 } },
        // cheat: S is an L-shape (from looking at the grid)
        'L', 'S' => .{ .{ 0, -1 }, .{ 1, 0 } },
        'J' => .{ .{ 0, -1 }, .{ -1, 0 } },
        '7' => .{ .{ 0, 1 }, .{ -1, 0 } },
        'F' => .{ .{ 1, 0 }, .{ 0, 1 } },
        else => null,
    };
}
