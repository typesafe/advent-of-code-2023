const std = @import("std");
const testing = std.testing;
const Input = @import("Input.zig");

test "day 1, part 1" {
    var it = try Input.readLines("src/day1.txt", testing.allocator);
    defer it.deinit() catch unreachable;

    var v: u32 = 0;
    while (it.next()) |line| {
        v += try getCalibrationValue(line);
    }

    std.debug.print("solution: {}\n", .{v});
}

fn getCalibrationValue(s: []const u8) !u32 {
    var first: u8 = 0;
    var last: u8 = 0;

    for (s) |c| {
        if (std.ascii.isDigit(c)) {
            if (first == 0) {
                first = c;
            }
            last = c;
        }
    }

    return try std.fmt.parseInt(u32, &.{ first, last }, 10);
}

test "day 1, part 2" {
    var it = try Input.readLines("src/day1.txt", testing.allocator);
    defer it.deinit() catch unreachable;

    var v: u32 = 0;
    while (it.next()) |line| {
        v += try getCalibrationValue2(line);
    }

    std.debug.print("solution: {}\n", .{v});
}

fn getCalibrationValue2(s: []const u8) !u32 {
    var first: u8 = 0;
    var last: u8 = 0;
    var pos: u32 = 0;

    for (s) |c| {
        pos += 1; // position is 1-based

        if (std.ascii.isDigit(c)) {
            if (first == 0) {
                first = c;
            }
            last = c;
        } else if (alignsWithDigitWord(s, pos)) |v| {
            if (first == 0) {
                first = v;
            }
            last = v;
        }
    }

    return try std.fmt.parseInt(u32, &.{ first, last }, 10);
}

fn alignsWithDigitWord(s: []const u8, pos: u32) ?u8 {
    for (digitWords.kvs) |kv| {
        const word = kv.key;

        if (pos < word.len) {
            continue;
        } else {
            const start = pos - word.len;

            if (std.mem.eql(u8, word, s[start..pos])) {
                return kv.value;
            }
        }
    }

    return null;
}

const digitWords = std.ComptimeStringMap(u8, .{
    .{ "one", '1' },
    .{ "two", '2' },
    .{ "three", '3' },
    .{ "four", '4' },
    .{ "five", '5' },
    .{ "six", '6' },
    .{ "seven", '7' },
    .{ "eight", '8' },
    .{ "nine", '9' },
});
