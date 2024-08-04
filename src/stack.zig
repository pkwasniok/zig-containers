const std = @import("std");
const LinkedList = @import("linked_list.zig").LinkedList;

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();

        linked_list: LinkedList(T),

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .linked_list = LinkedList(T).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.linked_list.deinit();
        }

        pub fn push(self: *Self, item: T) !void {
            try self.linked_list.push_front(item);
        }

        pub fn pop(self: *Self) ?T {
            return self.linked_list.pop_front();
        }
    };
}

test "Stack" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var stack = Stack(u32).init(allocator);
    defer stack.deinit();

    try stack.push(1);
    try stack.push(2);
    try stack.push(3);

    try std.testing.expect(stack.pop() == 3);
    try std.testing.expect(stack.pop() == 2);
    try std.testing.expect(stack.pop() == 1);
    try std.testing.expect(stack.pop() == null);
}
