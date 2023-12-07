const std = @import("std");
const testing = std.testing;
const Input = @import("Input.zig");

test "day 7, part 1" {
    var lines = try Input.readLines("src/day7.txt", testing.allocator);
    defer lines.deinit() catch unreachable;

    const hands = try parseHands(Hand, lines, testing.allocator);
    defer {
        for (hands) |hand| {
            var h = hand;
            h.deinit();
        }
        testing.allocator.free(hands);
    }

    var score: usize = 0;
    for (hands, 1..) |hand, exp| {
        score += hand.bid * exp;
    }

    std.debug.print("solution: {}\n", .{score});
    try testing.expect(score == 248179786);
}

test "day 7, part 2" {
    var lines = try Input.readLines("src/day7.txt", testing.allocator);
    defer lines.deinit() catch unreachable;

    const hands = try parseHands(HandWithJokers, lines, testing.allocator);
    defer {
        for (hands) |hand| {
            var h = hand;
            h.deinit();
        }
        testing.allocator.free(hands);
    }

    var score: usize = 0;
    for (hands, 1..) |hand, exp| {
        score += hand.bid * exp;
    }

    std.debug.print("solution: {}\n", .{score});
    try testing.expect(score == 247885995);
}

fn parseHands(comptime T: type, lines: Input.InputIterator, allocator: std.mem.Allocator) ![]T {
    var hands = std.ArrayList(T).init(allocator);

    while (lines.next()) |line| {
        try hands.append(try T.init(line, allocator));
    }

    const slice = try hands.toOwnedSlice();

    std.sort.insertion(T, slice, {}, T.sort);

    return slice;
}

const HandWithJokers = struct {
    input: []const u8,
    cards: std.AutoHashMap(usize, usize),
    strength: usize,
    bid: usize,

    pub fn init(data: []const u8, allocator: std.mem.Allocator) !@This() {
        var cards = std.AutoHashMap(usize, usize).init(allocator);
        var strength: usize = 0;
        var highestCount: usize = 0;
        var jokers: usize = 0;

        for (data[0..5], 0..) |card, exp| {
            const val = cardValuesWithJoker.get(&.{card}).?;
            strength += val * std.math.pow(usize, 15, 4 - exp);

            if (val == 1) {
                jokers += 1;
                continue; // we use jokers later
            }

            const count = if (cards.get(val)) |count| count else 0;
            try cards.put(val, count + 1);
            if (count + 1 > highestCount) {
                highestCount = count + 1;
            }
        }

        if (jokers == 5) {
            strength += @as(usize, 5) * std.math.pow(usize, 15, 4 + 5);
        }

        var it = cards.valueIterator();
        while (it.next()) |count| {
            if (count.* == highestCount and jokers > 0) {
                const funnyCount = count.* + jokers;
                strength += @as(usize, funnyCount) * std.math.pow(usize, 15, 4 + funnyCount);
                jokers = 0;
            } else if (count.* > 1) {
                strength += @as(usize, count.*) * std.math.pow(usize, 15, 4 + count.*);
            }
        }

        return @This(){
            .input = data,
            .cards = cards,
            .strength = strength,
            .bid = @as(usize, @bitCast(Input.parseInt(data[6..]))),
        };
    }

    pub fn deinit(self: *@This()) void {
        self.cards.deinit();
    }

    fn sort(_: void, a: @This(), b: @This()) bool {
        return a.strength < b.strength;
    }
};

const Hand = struct {
    cards: std.AutoHashMap(usize, usize),
    strength: usize,
    bid: usize,

    pub fn init(data: []const u8, allocator: std.mem.Allocator) !Hand {
        var cards = std.AutoHashMap(usize, usize).init(allocator);
        var strength: usize = 0;

        for (data[0..5], 0..) |card, exp| {
            const val = cardValues.get(&.{card}).?;
            strength += val * std.math.pow(usize, 15, 4 - exp);
            const count = if (cards.get(val)) |count| count else 0;
            try cards.put(val, count + 1);
        }

        var it = cards.valueIterator();
        while (it.next()) |count| {
            if (count.* > 1) {
                strength += @as(usize, count.*) * std.math.pow(usize, 15, 4 + count.*);
            }
        }

        return Hand{
            .cards = cards,
            .strength = strength,
            .bid = @as(usize, @bitCast(Input.parseInt(data[6..]))),
        };
    }

    pub fn deinit(self: *Hand) void {
        self.cards.deinit();
    }

    fn sort(_: void, a: Hand, b: Hand) bool {
        return a.strength < b.strength;
    }
};

const cardValues = std.ComptimeStringMap(usize, .{
    .{ "2", 2 },
    .{ "3", 3 },
    .{ "4", 4 },
    .{ "5", 5 },
    .{ "6", 6 },
    .{ "7", 7 },
    .{ "8", 8 },
    .{ "9", 9 },
    .{ "T", 10 },
    .{ "J", 11 },
    .{ "Q", 12 },
    .{ "K", 13 },
    .{ "A", 14 },
});

const cardValuesWithJoker = std.ComptimeStringMap(usize, .{
    .{ "2", 2 },
    .{ "3", 3 },
    .{ "4", 4 },
    .{ "5", 5 },
    .{ "6", 6 },
    .{ "7", 7 },
    .{ "8", 8 },
    .{ "9", 9 },
    .{ "T", 10 },
    .{ "J", 1 }, // 1 < 2
    .{ "Q", 12 },
    .{ "K", 13 },
    .{ "A", 14 },
});

// '2' -> 48
// '3' -> 49
// ...
// '9' -> 57
// 'A' -> 65
// 'B' -> 66
// 'C' -> 67
// 'D' -> 68
// 'E' -> 69
// 'F' -> 70
// 'T' -> 84
