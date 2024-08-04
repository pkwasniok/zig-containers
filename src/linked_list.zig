const std = @import("std");

pub fn LinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        const Node = struct {
            value: T,
            next: ?*Node,
            prev: ?*Node,
        };

        allocator: std.mem.Allocator,
        head: ?*Node,
        tail: ?*Node,
        len: usize,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .allocator = allocator,
                .head = null,
                .tail = null,
                .len = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            while (self.pop_back()) |_| {}
        }

        pub fn push_front(self: *Self, item: T) !void {
            // Create node
            var node = try self.allocator.create(Node);
            node.value = item;
            node.prev = self.head;
            node.next = null;

            // Link node
            if (self.head) |_| {
                self.head.?.next = node;
                self.head = node;
            } else {
                self.head = node;
                self.tail = node;
            }

            self.len += 1;
        }

        pub fn push_back(self: *Self, item: T) !void {
            // Create node
            var node = try self.allocator.create(Node);
            node.value = item;
            node.prev = null;
            node.next = self.tail;

            // Link node
            if (self.tail) |_| {
                self.tail.?.prev = node;
                self.tail = node;
            } else {
                self.tail = node;
                self.head = node;
            }

            self.len += 1;
        }

        pub fn pop_front(self: *Self) ?T {
            if (self.head) |head| {
                // Unlink node
                self.head = head.prev;
                if (self.head == null) {
                    self.tail = null;
                } else {
                    self.head.?.next = null;
                }

                // Destroy node
                const item = head.value;
                self.allocator.destroy(head);

                self.len -= 1;

                return item;
            }

            return null;
        }

        pub fn pop_back(self: *Self) ?T {
            if (self.tail) |tail| {
                // Unlink node
                self.tail = tail.next;
                if (self.tail == null) {
                    self.head = null;
                } else {
                    self.tail.?.prev = null;
                }

                // Destroy node
                const item = tail.value;
                self.allocator.destroy(tail);

                self.len -= 1;

                return item;
            }

            return null;
        }

        pub fn get(self: *Self, index: usize) ?T {
            var current = self.tail;

            for (0..index) |_| {
                if (current == null) {
                    return null;
                }
                current = current.?.next;
            }

            if (current) |node| {
                return node.value;
            }

            return null;
        }
    };
}

test "LinkedList" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var linked_list = LinkedList(u32).init(allocator);
    defer linked_list.deinit();

    try linked_list.push_front(1);
    try linked_list.push_front(2);
    try linked_list.push_front(3);
    try linked_list.push_front(4);
    try linked_list.push_front(5);

    try std.testing.expect(linked_list.get(2) == 3);
    try std.testing.expect(linked_list.get(10) == null);
}
