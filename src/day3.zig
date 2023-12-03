const std = @import("std");
const testing = std.testing;
const Input = @import("Input.zig");

test "day 2, part 1" {
    var list = std.ArrayList([]const u8).init(testing.allocator);
    defer list.deinit();

    var it = try Input.readLines("src/day3.txt", testing.allocator);
    defer it.deinit() catch unreachable;

    while (it.next()) |line| {
        try list.append(line);
    }

    var sum: u32 = 0;

    for (0..list.items.len) |y| {
        const line = list.items[y];
        var candidateStart: ?usize = null;

        for (0..line.len) |x| {
            if (isDigit(line, x)) {
                if (candidateStart == null) {
                    candidateStart = x;
                }
            } else if (candidateStart != null) {
                const v = try std.fmt.parseInt(u32, line[candidateStart.?..x], 10);

                if (hasAdjacentDigits(list, y, candidateStart.?, x - 1)) {
                    sum += v;
                }

                candidateStart = null;
            }
        }

        if (candidateStart != null) {
            const v = try std.fmt.parseInt(u32, line[candidateStart.?..line.len], 10);

            if (hasAdjacentDigits(list, y, candidateStart.?, line.len - 1)) {
                sum += v;
            }
        }
    }

    std.debug.print("solution: {}\n", .{sum});
}

fn hasAdjacentDigits(map: std.ArrayList([]const u8), y: usize, x1: usize, x2: usize) bool {
    if (x1 > 0 and isSymbol(map.items[y], x1 - 1)) {
        return true;
    }

    if (x2 < map.items[y].len - 1 and isSymbol(map.items[y], x2 + 1)) {
        return true;
    }

    if (y > 0 and containsDigits(map.items[y - 1], x1, x2)) {
        return true;
    }

    if (y < map.items.len - 1 and containsDigits(map.items[y + 1], x1, x2)) {
        return true;
    }

    return false;
}

fn containsDigits(line: []const u8, x1: usize, x2: usize) bool {
    const from = if (x1 == 0) 0 else x1 - 1;
    const to = @min(x2 + 1, line.len - 1);

    for (from..to + 1) |x| {
        if (isSymbol(line, x)) {
            return true;
        }
    }

    return false;
}

fn isSymbol(s: []const u8, i: usize) bool {
    return s[i] != '.' and !isDigit(s, i);
}

fn isDigit(s: []const u8, i: usize) bool {
    return std.ascii.isDigit(s[i]);
}
