const std = @import("std");
const testing = std.testing;
const Input = @import("Input.zig");

test "day 7, part 1" {
    var lines = try Input.readLines("src/day7.txt", testing.allocator);
    defer lines.deinit() catch unreachable;

    const hands = try parseHands(lines, testing.allocator);
    defer {
        for (hands) |hand| {
            var h = hand;
            h.deinit();
        }
        testing.allocator.free(hands);
    }

    std.sort.insertion(Hand, hands, {}, Hand.sort);

    var score: usize = 0;
    for (hands, 1..) |hand, exp| {
        score += hand.bid * exp;
    }

    std.debug.print("solution: {}\n", .{score});
    try testing.expect(score == 248179786);
}

fn parseHands(lines: Input.InputIterator, allocator: std.mem.Allocator) ![]Hand {
    var hands = std.ArrayList(Hand).init(allocator);

    while (lines.next()) |line| {
        try hands.append(try Hand.init(line, allocator));
    }

    return hands.toOwnedSlice();
}

const Hand = struct {
    input: []const u8,
    cards: std.AutoHashMap(usize, usize),
    strength: usize,
    bid: usize,

    pub fn init(data: []const u8, allocator: std.mem.Allocator) !Hand {
        // var cards = std.AutoHashMap(u8, u8).init(allocator);

        // for (data[0..5]) |card| {
        //     const val = cardValues.get(&.{card}).?;
        //     const count = if (cards.get(val)) |count| count else 0;
        //     try cards.put(val, count + 1);
        // }

        // var strength: usize = 0;
        // var it = cards.iterator();
        // while (it.next()) |entry| {
        //     const val = @as(usize, entry.key_ptr.*);
        //     const exp = @as(usize, entry.value_ptr.* - 1);
        //     // std.debug.print("key: {}\n", .{val});
        //     // std.debug.print("key: {}\n", .{exp});

        //     strength += val * 100 ^ exp;
        // }

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
            .input = data,
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
