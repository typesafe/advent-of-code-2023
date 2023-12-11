const std = @import("std");
const testing = std.testing;
const Input = @import("Input.zig");

test "day 11, part 1" {
    const solution = try solve(2);
    try testing.expect(solution == 9681886);
}

test "day 11, part 2" {
    const solution = try solve(1_000_000);
    try testing.expect(solution == 791134099634);
}

fn solve(expansion: usize) !usize {
    var aa = std.heap.ArenaAllocator.init(testing.allocator);
    defer aa.deinit();
    const allocator = aa.allocator();

    const grid = try Input.readGrid("src/day11.txt", 140, 140, testing.allocator);
    defer grid.deinit();

    var emptyRows = std.AutoHashMap(usize, void).init(allocator);
    var emptyCols = std.AutoHashMap(usize, void).init(allocator);
    var galaxies = std.ArrayList([2]usize).init(allocator);

    rows: for (0..140) |y| {
        for (0..140) |x| {
            if (grid.get(x, y) == '#') {
                continue :rows;
            }
        }
        try emptyRows.put(y, {});
    }

    cols: for (0..140) |x| {
        for (0..140) |y| {
            if (grid.get(x, y) == '#') {
                continue :cols;
            }
        }
        try emptyCols.put(x, {});
    }

    var yy: usize = 0;
    for (0..140) |y| {
        if (emptyRows.contains(y)) {
            yy += expansion - 1;
        }
        var xx: usize = 0;
        for (0..140) |x| {
            if (emptyCols.contains(x)) {
                xx += expansion - 1;
            }

            if (grid.get(x, y) == '#') {
                try galaxies.append(.{ x + xx, y + yy });
            }
        }
    }

    var solution: usize = 0;

    while (galaxies.items.len > 0) {
        const a = galaxies.pop();
        for (galaxies.items) |b| {
            solution += @max(b[0], a[0]) - @min(b[0], a[0]) + @max(b[1], a[1]) - @min(b[1], a[1]);
        }
    }

    std.debug.print("solution: {any}\n", .{solution});
    return solution;
}
