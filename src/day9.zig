const std = @import("std");
const testing = std.testing;
const Input = @import("Input.zig");

test "day 9, part 1" {
    var lines = try Input.readLines("src/day9.txt", testing.allocator);
    defer lines.deinit() catch unreachable;

    var sumOrPredictions: isize = 0;
    while (lines.next()) |line| {
        const inputValues = try parseNumbers(line, testing.allocator);
        defer testing.allocator.free(inputValues);

        const prediction = predict(inputValues);
        sumOrPredictions += prediction;
    }

    std.debug.print("solution: {any}\n", .{sumOrPredictions});
    try testing.expect(sumOrPredictions == 1995001648);
}

test "day 9, part 2" {
    var lines = try Input.readLines("src/day9.txt", testing.allocator);
    defer lines.deinit() catch unreachable;

    var sumOrPredictions: isize = 0;
    while (lines.next()) |line| {
        const inputValues = try parseNumbers(line, testing.allocator);
        std.mem.reverse(isize, inputValues);
        defer testing.allocator.free(inputValues);

        const prediction = predict(inputValues);
        sumOrPredictions += prediction;
    }

    std.debug.print("solution: {any}\n", .{sumOrPredictions});
    try testing.expect(sumOrPredictions == 988);
}

fn predict(inputValues: []isize) isize {
    var prediction: isize = 0;

    var completed = false;
    var windowSize = inputValues.len - 1;
    while (!completed) {
        var allZero = true;
        for (0..windowSize) |i| {
            inputValues[i] = inputValues[i + 1] - inputValues[i];
            if (inputValues[i] != 0) {
                allZero = false;
            }
        }
        if (allZero) {
            completed = true;
        }
        prediction += inputValues[windowSize];
        windowSize -= 1;
    }

    return prediction;
}

fn parseNumbers(s: []const u8, allocator: std.mem.Allocator) ![]isize {
    var parts = std.mem.splitScalar(u8, s, ' ');
    var result = std.ArrayList(isize).init(allocator);

    while (parts.next()) |part| {
        try result.append(try std.fmt.parseInt(isize, part, 10));
    }

    return result.toOwnedSlice();
}
