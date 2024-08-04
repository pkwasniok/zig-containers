const std = @import("std");
const linked_list = @import("linked_list.zig");
const LinkedList = linked_list.LinkedList;

pub fn Queue(comptime T: type) type {
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

        pub fn enqueue(self: *Self, item: T) !void {
            try self.linked_list.push_front(item);
        }

        pub fn dequeue(self: *Self) ?T {
            return self.linked_list.pop_back();
        }
    };
}

test "Queue" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var queue = Queue(u32).init(allocator);
    defer queue.deinit();

    try queue.enqueue(1);
    try queue.enqueue(2);
    try queue.enqueue(3);
    try queue.enqueue(4);
    try queue.enqueue(5);

    try std.testing.expect(queue.dequeue() == 1);
    try std.testing.expect(queue.dequeue() == 2);
    try std.testing.expect(queue.dequeue() == 3);
    try std.testing.expect(queue.dequeue() == 4);
    try std.testing.expect(queue.dequeue() == 5);
    try std.testing.expect(queue.dequeue() == null);
}
