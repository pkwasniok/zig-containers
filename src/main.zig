const std = @import("std");
const collections = @import("./root.zig");

const TreeNode = struct {
    value: u32,
    left: ?*TreeNode,
    right: ?*TreeNode,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    _ = allocator;
}
