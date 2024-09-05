const std = @import("std");

//
// # Singly linked list
//
// ## Diagram
//      *prev
//        |
// value  |
//   |    |
// ---------
// | x | * |
// ---------
//
//   *head
//     |
// ┏━━━┳━━━┓    ┏━━━┳━━━┓    ┏━━━┳━━━┓    ┏━━━┳━━━┓
// ┃ 1 ┃ * ┃ -> ┃ 2 ┃ * ┃ -> ┃ 3 ┃ * ┃ -> ┃ 4 ┃ * ┃ -> null
// ┗━━━┻━━━┛    ┗━━━┻━━━┛    ┗━━━┻━━━┛    ┗━━━┻━━━┛
// |<- FRONT                               BACK ->|
//
// ## Operations
// - `push`
//   Insert new element into list. Time complexity: O(1).
// - `pop`
//   Remove youngest element from list. Time complexity: O(1).
//

pub fn SinglyLinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        const Node = struct {
            value: T,
            prev: ?*Node,
        };

        allocator: std.mem.Allocator,
        head: ?*Node,
        len: usize,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .allocator = allocator,
                .head = null,
                .len = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            while (self.pop()) |_| {}
        }

        pub fn push(self: *Self, item: T) !void {
            // Create new node
            var node = try self.allocator.create(Node);
            node.value = item;
            node.prev = self.head;

            // Update head
            self.head = node;

            self.len += 1;
        }

        pub fn pop(self: *Self) ?T {
            if (self.head) |node| {
                // Update head & copy value
                self.head = node.prev;
                const item = node.value;

                // Destroy node
                self.allocator.destroy(node);

                self.len -= 1;

                return item;
            }

            return null;
        }

        pub fn len(self: *Self) usize {
            return self.len;
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

test "SinglyLinkedList deinit" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var linked_list = SinglyLinkedList(u32).init(allocator);
    defer linked_list.deinit();

    try linked_list.push(1);
    try linked_list.push(2);
    try linked_list.push(3);
}
