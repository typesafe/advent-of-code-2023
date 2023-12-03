const std = @import("std");

test "aoc" {
    _ = @import("./day1.zig");
    _ = @import("./day2.zig");
    _ = @import("./day3.zig");
}

test {
    std.testing.refAllDeclsRecursive(@This());
}
