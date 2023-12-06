const std = @import("std");
const testing = std.testing;

pub fn readFile(path: []const u8, allocator: std.mem.Allocator) ![]const u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const buffer = try allocator.alloc(u8, try file.getEndPos());

    _ = try file.readAll(buffer);

    return buffer;
}

pub fn readLines(path: []const u8, allocator: std.mem.Allocator) !InputIterator {
    const buffer = readFile(path, allocator);

    return InputIterator.init(buffer, allocator);
}

pub fn parseInts(iterator: anytype, comptime len: usize) [len]isize {
    var result: [len]isize = undefined;
    var it = iterator;
    var i: u8 = 0;
    while (it.next()) |v| {
        result[i] = parseInt(v);
        i += 1;
    }
    return result;
}

pub fn parseInt(s: []const u8) isize {
    return std.fmt.parseInt(isize, s, 10) catch 0;
}

pub const InputIterator = struct {
    it: *std.mem.SplitIterator(u8, .scalar),
    buffer: []const u8,
    allocator: std.mem.Allocator,

    pub fn init(buffer: []const u8, allocator: std.mem.Allocator) !InputIterator {
        const it = try allocator.create(std.mem.SplitIterator(u8, .scalar));
        it.* = std.mem.splitScalar(u8, buffer, '\n');
        return InputIterator{
            .it = it,
            .buffer = buffer,
            .allocator = allocator,
        };
    }

    pub fn next(self: @This()) ?[]const u8 {
        if (self.it.next()) |v| {
            return v;
        } else {
            return null;
        }
    }

    pub fn deinit(self: @This()) !void {
        self.allocator.free(self.buffer);
        self.allocator.destroy(self.it);
    }
};
