const std = @import("std");

// Singly linked list
//
// Diagram:
// *-> *head
// |
// ---------    ---------    ---------    ---------
// | 1 | * | -> | 2 | * | -> | 3 | * | -> | 4 | * | -> null
// ---------    ---------    ---------    --------
//
// Operations:
// - push
//   Insert new element into list. Time complexity: O(1).
// - pop
//   Remove youngest element from list. Time complexity: O(1).

pub fn SinglyLinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        const Node = struct {
            value: T,
            next: ?*Node,
        };

        allocator: std.mem.Allocator,
        head: ?*Node,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .allocator = allocator,
                .head = null,
            };
        }

        pub fn deinit(self: *Self) void {
            while (self.pop()) |_| {}
        }

        pub fn push(self: *Self, item: T) !void {
            // Create new node
            var node = try self.allocator.create(Node);
            node.value = item;
            node.next = self.head;

            // Update head
            self.head = node;
        }

        pub fn pop(self: *Self) ?T {
            if (self.head) |node| {
                // Update head & copy value
                self.head = node.next;
                const item = node.value;

                // Destroy node
                self.allocator.destroy(node);

                return item;
            }

            return null;
        }
    };
}

test "SinglyLinkedList" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var linked_list = SinglyLinkedList(u32).init(allocator);
    defer linked_list.deinit();

    try linked_list.push(1);
    try linked_list.push(2);
    try linked_list.push(3);

    try std.testing.expect(linked_list.pop() == 3);
    try std.testing.expect(linked_list.pop() == 2);
    try std.testing.expect(linked_list.pop() == 1);
    try std.testing.expect(linked_list.pop() == null);
}
