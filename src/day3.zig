const std = @import("std");
const testing = std.testing;
const Input = @import("Input.zig");

test "day 2, part 1" {
    var it = try Input.readLines("src/day3.txt", testing.allocator);
    defer it.deinit() catch unreachable;

    var list = std.ArrayList([]const u8).init(testing.allocator);
    defer list.deinit();

    while (it.next()) |line| {
        try list.append(line);
    }

    var sum: u32 = 0;

    for (0..list.items.len) |y| {
        const line = list.items[y];
        var candidateStart: ?usize = null;

        for (0..line.len) |x| {
            if (isDigit(line, x) and candidateStart == null) {
                candidateStart = x;
            }

            if (candidateStart != null) {
                if (!isDigit(line, x)) {
                    const v = try std.fmt.parseInt(u32, line[candidateStart.?..x], 10);

                    if (hasAdjacentDigits(list, y, candidateStart.?, x - 1)) {
                        sum += v;
                    }

                    candidateStart = null;
                } else if (x == line.len - 1) {
                    const v = try std.fmt.parseInt(u32, line[candidateStart.?..line.len], 10);

                    if (hasAdjacentDigits(list, y, candidateStart.?, x)) {
                        sum += v;
                    }

                    candidateStart = null;
                }
            }
        }
    }

    std.debug.print("solution: {}\n", .{sum});
    try testing.expect(sum == 525119);
}

test "day 2, part 2" {
    var list = std.ArrayList([]const u8).init(testing.allocator);
    defer list.deinit();

    var it = try Input.readLines("src/day3.txt", testing.allocator);
    defer it.deinit() catch unreachable;

    while (it.next()) |line| {
        try list.append(line);
    }

    var gears = std.AutoHashMap([2]usize, [2]u32).init(testing.allocator);
    defer gears.deinit();

    for (0..list.items.len) |y| {
        const line = list.items[y];
        var candidateStart: ?usize = null;

        for (0..line.len) |x| {
            if (isDigit(line, x) and candidateStart == null) {
                candidateStart = x;
            }

            if (candidateStart != null) {
                if (!isDigit(line, x)) {
                    const v = try std.fmt.parseInt(u32, line[candidateStart.?..x], 10);

                    if (hasAdjacentGear(list, y, candidateStart.?, x - 1)) |gear| {
                        const current = gears.get(gear) orelse .{ 0, 1 };
                        try gears.put(gear, .{ current[0] + 1, current[1] * v });
                    }

                    candidateStart = null;
                } else if (x == line.len - 1) {
                    const v = try std.fmt.parseInt(u32, line[candidateStart.?..line.len], 10);

                    if (hasAdjacentGear(list, y, candidateStart.?, x)) |gear| {
                        const current = gears.get(gear) orelse .{ 0, 1 };
                        try gears.put(gear, .{ current[0] + 1, current[1] * v });
                    }

                    candidateStart = null;
                }
            }
        }
    }

    var sum: u32 = 0;
    var values = gears.iterator();
    while (values.next()) |e| {
        if (e.value_ptr.*[0] == 2) {
            sum += e.value_ptr.*[1];
        }
    }

    std.debug.print("solution: {}\n", .{sum});
    try testing.expect(sum == 76504829);
}

fn hasAdjacentGear(map: std.ArrayList([]const u8), y: usize, x1: usize, x2: usize) ?[2]usize {
    if (x1 > 0 and isGear(map.items[y], x1 - 1)) {
        return .{ x1 - 1, y };
    }

    if (x2 < map.items[y].len - 1 and isGear(map.items[y], x2 + 1)) {
        return .{ x2 + 1, y };
    }

    if (y > 0) {
        if (containsGear(map.items[y - 1], x1, x2)) |x| {
            return .{ x, y - 1 };
        }
    }

    if (y < map.items.len - 1) {
        if (containsGear(map.items[y + 1], x1, x2)) |x| {
            return .{ x, y + 1 };
        }
    }

    return null;
}

fn hasAdjacentDigits(map: std.ArrayList([]const u8), y: usize, x1: usize, x2: usize) bool {
    if (x1 > 0 and isSymbol(map.items[y], x1 - 1)) {
        return true;
    }

    if (x2 < map.items[y].len - 1 and isSymbol(map.items[y], x2 + 1)) {
        return true;
    }

    if (y > 0 and containsSymbols(map.items[y - 1], x1, x2)) {
        return true;
    }

    if (y < map.items.len - 1 and containsSymbols(map.items[y + 1], x1, x2)) {
        return true;
    }

    return false;
}

fn containsSymbols(line: []const u8, x1: usize, x2: usize) bool {
    const from = if (x1 == 0) 0 else x1 - 1;
    const to = @min(x2 + 1, line.len - 1);

    for (from..to + 1) |x| {
        if (isSymbol(line, x)) {
            return true;
        }
    }

    return false;
}

fn containsGear(line: []const u8, x1: usize, x2: usize) ?usize {
    const from = if (x1 == 0) 0 else x1 - 1;
    const to = @min(x2 + 1, line.len - 1);

    for (from..to + 1) |x| {
        if (isSymbol(line, x)) {
            return x;
        }
    }

    return null;
}

fn isGear(s: []const u8, i: usize) bool {
    return s[i] == '*';
}

fn isSymbol(s: []const u8, i: usize) bool {
    return s[i] != '.' and !isDigit(s, i);
}

fn isDigit(s: []const u8, i: usize) bool {
    return std.ascii.isDigit(s[i]);
}
