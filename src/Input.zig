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
    const buffer = try readFile(path, allocator);

    return try InputIterator.init(buffer, allocator);
}

pub fn readGrid(path: []const u8, width: usize, height: usize, allocator: std.mem.Allocator) !Grid {
    const buffer = try readFile(path, allocator);

    return Grid.init(buffer, width, height, allocator);
}

pub const Grid = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    buffer: []const u8,
    width: usize,
    height: usize,

    pub fn init(buffer: []const u8, width: usize, height: usize, allocator: std.mem.Allocator) Self {
        return Self{
            .allocator = allocator,
            .buffer = buffer,
            .width = width,
            .height = height,
        };
    }

    pub fn get(self: Self, x: usize, y: usize) u8 {
        return self.buffer[x + y * (self.width + 1)]; // +1 for the '\n' delimiter
    }

    pub fn deinit(self: Self) void {
        self.allocator.free(self.buffer);
    }
};

pub fn readLinesAsSlice(path: []const u8, allocator: std.mem.Allocator) ![][]const u8 {
    var lines = try readLines(path, allocator);
    defer lines.deinit() catch unreachable;

    var list = std.ArrayList([]const u8).init(allocator);

    while (lines.next()) |line| {
        try list.append(try allocator.dupe(u8, line));
    }

    return list.toOwnedSlice();
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
