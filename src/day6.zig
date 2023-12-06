const std = @import("std");
const testing = std.testing;
const Input = @import("Input.zig");

test "day 6, part 1" {
    // let's not bother parsing this time...
    const games: []const Game = &.{
        Game{ .time = 44, .record = 202 },
        Game{ .time = 82, .record = 1076 },
        Game{ .time = 69, .record = 1138 },
        Game{ .time = 81, .record = 1458 },
    };

    var score: usize = 1;

    for (games) |game| {
        var waysToWin: usize = 0;
        for (1..game.time) |speed| {
            const raceTime = game.time - speed;
            const record = speed * raceTime; // [ (mm / ms) * ms]
            if (record > game.record) {
                waysToWin += 1;
            }
        }
        score = score * waysToWin;
    }

    std.debug.print("solution: {}\n", .{score});
    try testing.expect(score == 588588);
}

test "day 6, part 2 - naïve" {
    const games: []const Game = &.{
        Game{ .time = 44826981, .record = 202107611381458 },
    };

    var score: usize = 1;

    for (games) |game| {
        std.debug.print("time: {}, dist: {}\n", .{ game.time, game.record });
        var betterDistances: usize = 0;
        for (1..game.time) |speed| {
            const raceTime = game.time - speed;
            const distance = speed * raceTime; // [ (mm / ms) * ms]
            if (distance > game.record) {
                betterDistances += 1;
                //std.debug.print("speed/button time: {}\n", .{speed});
            }
        }
        score = score * betterDistances;
    }

    std.debug.print("solution: {}\n", .{score});
    try testing.expect(score == 34655848);
}

test "day 6, part 2 O(n)" {
    // the distribution is a parabola with the maximum at T/2
    // so we can simply solve this equation

    // x * (T - x) = R
    // => x^2 - T*x + R > 0
    // => x^2 - T*x + R + 1 = 0
    // => x = (T +/- sqrt(T^2 - 4*R - 4)) / 2

    const T = 44_826_981;
    const R = 202_107_611_381_458;

    // the (one but) first number of seconds a button press would still result in a better distance
    const lower = (T - std.math.sqrt(T * T - 4 * R - 4)) / 2;
    // the last number of seconds a button press would still result in a better distance
    const upper = (T + std.math.sqrt(T * T - 4 * R - 4)) / 2;

    const score = upper - lower + 1; // minimum is 0, so we need to add 1 (i.e. we're _counting_ here)
    std.debug.print("solution: {} (from {} to {}) \n", .{ score, upper, lower });
    try testing.expect(score == 34655848);
}

const Game = struct {
    time: usize,
    record: usize,
};
