const std = @import("std");
const testing = std.testing;

pub fn readLines(path: []const u8, allocator: std.mem.Allocator) !InputIterator {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const buffer = try allocator.alloc(u8, try file.getEndPos());

    _ = try file.readAll(buffer);

    return InputIterator.init(buffer, allocator);
}

pub const InputIterator = struct {
    it: *std.mem.SplitIterator(u8, .scalar),
    buffer: []const u8,
    allocator: std.mem.Allocator,

    pub fn init(buffer: []const u8, allocator: std.mem.Allocator) !InputIterator {
        var it = try allocator.create(std.mem.SplitIterator(u8, .scalar));
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
