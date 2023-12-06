const std = @import("std");
const testing = std.testing;
const Input = @import("Input.zig");

test "day 4, part 1" {
    var cards = try Input.readLines("src/day4.txt", testing.allocator);
    defer cards.deinit() catch unreachable;

    var sum: u32 = 0;

    while (cards.next()) |card| {
        var headerAndData = std.mem.splitScalar(u8, card, ':');
        _ = headerAndData.next().?;
        const data = headerAndData.next().?;

        var winningAndReceived = std.mem.splitScalar(u8, data, '|');
        const winning = try parseNumbers(winningAndReceived.next().?, 10);
        const received = try parseNumbers(winningAndReceived.next().?, 25);

        sum += matchReceivedWinningNumbers(winning, received);
    }

    std.debug.print("solution: {}\n", .{sum});
    try testing.expect(sum == 28538);
}

test "day 4, part 2" {
    var cards = try Input.readLines("src/day4.txt", testing.allocator);
    defer cards.deinit() catch unreachable;

    var duplications = std.mem.zeroes([220]u32);

    var sum: u32 = 0;
    var i: u32 = 0;

    while (cards.next()) |card| {
        var headerAndData = std.mem.splitScalar(u8, card, ':');
        _ = headerAndData.next().?;
        const data = headerAndData.next().?;

        var winningAndReceived = std.mem.splitScalar(u8, data, '|');
        const winning = try parseNumbers(winningAndReceived.next().?, 10);
        const received = try parseNumbers(winningAndReceived.next().?, 25);

        const count = countReceivedWinningNumbers(winning, received);

        for (1..count + 1) |offset| {
            const index = i + offset;
            if (index > duplications.len) {
                break;
            }
            duplications[index] += duplications[i] + 1;
        }

        sum += duplications[i] + 1;
        i += 1;
    }

    std.debug.print("solution: {}\n", .{sum});
    try testing.expect(sum == 9425061);
}

fn countReceivedWinningNumbers(winning: [10]u32, received: [25]u32) u10 {
    var count: u10 = 0;

    var r: u5 = 0;
    var w: u5 = 0;

    while (w < winning.len and r < received.len) {
        if (winning[w] == received[r]) {
            count += 1;
            w += 1;
            r += 1;
        } else if (winning[w] < received[r]) {
            w += 1;
        } else {
            r += 1;
        }
    }

    return count;
}

fn matchReceivedWinningNumbers(winning: [10]u32, received: [25]u32) u10 {
    var score: u10 = 0;

    var r: u5 = 0;
    var w: u5 = 0;

    while (w < winning.len and r < received.len) {
        if (winning[w] == received[r]) {
            score = if (score == 0) 1 else score << 1;
            w += 1;
            r += 1;
        } else if (winning[w] < received[r]) {
            w += 1;
        } else {
            r += 1;
        }
    }

    return score;
}

/// Also sorts the numbers so that the matching can be done in O(n) time.
fn parseNumbers(s: []const u8, comptime count: u5) ![count]u32 {
    var parts = std.mem.splitScalar(u8, s, ' ');
    var result: [count]u32 = undefined;

    var i: u5 = 0;
    while (parts.next()) |part| {
        if (part.len > 0) { // skip empty parts
            result[i] = try std.fmt.parseInt(u32, part, 10);
            i += 1;
        }
    }

    std.sort.insertion(u32, &result, {}, std.sort.asc(u32));

    return result;
}
