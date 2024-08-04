const std = @import("std");
const collections = @import("./root.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var stack = collections.Stack(u32).init(allocator);
    defer stack.deinit();

    var linked_list = collections.LinkedList(u32).init(allocator);
    defer linked_list.deinit();

    var array_list = collections.ArrayList(u32).init(allocator);
    defer array_list.deinit();
}
