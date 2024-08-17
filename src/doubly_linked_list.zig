const std = @import("std");

// Doubly linked list
//
// Diagram:
//         *prev
//           |
//     value |
//       |   |
// *next |   |
//   |   |   |
// -------------
// | * | x | * |
// -------------
//
//              *head                                                 *tail
//                |                                                     |
//         -------------     -------------     -------------     -------------
// null <- | * | 1 | * | <-> | * | 2 | * | <-> | * | 3 | * | <-> | * | 4 | * | -> null
//         -------------     -------------     -------------     -------------
// |<- FRONT                                                                  BACK ->|
//
// Operations:
// - push_front
//   Insert new elements into front of the list. Time complexity: O(1).
// - push_back
//   Insert new element onto back of the list. Time complexity: O(1).
// - pop_front
//   Remove and return element from front of the list. Time complexity: O(1).
// - pop_back
//   Remove and return element from back of the list. Time complexity: O(1).

pub fn DoublyLinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        const Node = struct {
            value: T,
            prev: ?*Node,
            next: ?*Node,
        };

        allocator: std.mem.Allocator,
        head: ?*Node,
        tail: ?*Node,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .allocator = allocator,
                .head = null,
                .tail = null,
            };
        }

        pub fn deinit(self: *Self) void {
            while (self.pop_front()) |_| {}
        }

        pub fn push_front(self: *Self, item: T) !void {
            // Create new node
            var node = try self.allocator.create(Node);
            node.value = item;
            node.prev = self.head;
            node.next = null;

            if (self.head) |*head| {
                head.*.next = node;
                head.* = node;
            } else {
                self.head = node;
                self.tail = node;
            }
        }

        pub fn push_back(self: *Self, item: T) !void {
            // Create new node
            var node = try self.allocator.create(Node);
            node.value = item;
            node.prev = null;
            node.next = self.tail;

            if (self.tail) |*tail| {
                tail.*.prev = node;
                tail.* = node;
            } else {
                self.tail = node;
                self.head = node;
            }
        }

        pub fn pop_front(self: *Self) ?T {
            if (self.head) |node| {
                // Update head
                self.head = node.prev;
                if (self.head) |*head| {
                    head.*.next = null;
                }

                // Copy value
                const item = node.value;

                // Update tail when list is empty
                if (self.head == null) {
                    self.tail = null;
                }

                // Destroy node
                self.allocator.destroy(node);

                return item;
            }

            return null;
        }

        pub fn pop_back(self: *Self) ?T {
            if (self.tail) |node| {
                // Update tail
                self.tail = node.next;
                if (self.tail) |*tail| {
                    tail.*.prev = null;
                }

                // Copy value
                const item = node.value;

                // Update head when list is empty
                if (self.tail == null) {
                    self.head = null;
                }

                // Destroy node
                self.allocator.destroy(node);

                return item;
            }

            return null;
        }
    };
}

test "DoublyLinkedList" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var linked_list = DoublyLinkedList(u32).init(allocator);
    defer linked_list.deinit();

    try linked_list.push_front(1);
    try linked_list.push_front(2);
    try linked_list.push_front(3);

    try linked_list.push_back(1);
    try linked_list.push_back(2);
    try linked_list.push_back(3);

    try std.testing.expect(linked_list.pop_front() == 3);
    try std.testing.expect(linked_list.pop_front() == 2);
    try std.testing.expect(linked_list.pop_front() == 1);

    try std.testing.expect(linked_list.pop_back() == 3);
    try std.testing.expect(linked_list.pop_back() == 2);
    try std.testing.expect(linked_list.pop_back() == 1);

    try std.testing.expect(linked_list.pop_front() == null);
    try std.testing.expect(linked_list.pop_back() == null);
}
