const std = @import("std");
const ArrayList = @import("./array_list.zig").ArrayList;

pub fn BinaryHeap(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        tree: ArrayList(T),

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .allocator = allocator,
                .tree = ArrayList(T).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.tree.deinit();
        }

        pub fn push(self: *Self, item: T) !void {
            try self.tree.push_front(item);

            var current_index: usize = self.tree.items.len - 1;
            var parent_index: usize = (current_index -| 1) / 2;

            while (self.tree.items[current_index] < self.tree.items[parent_index]) {
                const temp = self.tree.items[current_index];
                self.tree.items[current_index] = self.tree.items[parent_index];
                self.tree.items[parent_index] = temp;

                current_index = parent_index;
                parent_index = (current_index -| 1) / 2;
            }
        }

        pub fn pop(self: *Self) ?T {
            if (self.tree.items.len == 0) {
                return null;
            }

            if (self.tree.items.len == 1) {
                return self.tree.pop_front();
            }

            const result = self.tree.items[0];

            self.tree.items[0] = self.tree.pop_front().?;

            var current_index: usize = 0;
            var left_child_index: usize = current_index * 2 + 1;
            var right_child_index: usize = current_index * 2 + 2;

            while (true) {
                var lowest_child_index: ?usize = null;

                if (self.tree.items.len >= right_child_index + 1 and self.tree.items[right_child_index] < self.tree.items[left_child_index]) {
                    lowest_child_index = right_child_index;
                } else if (self.tree.items.len >= left_child_index + 1) {
                    lowest_child_index = left_child_index;
                }

                if (lowest_child_index == null) {
                    break;
                }

                if (self.tree.items[current_index] > self.tree.items[lowest_child_index.?]) {
                    const temp = self.tree.items[current_index];
                    self.tree.items[current_index] = self.tree.items[lowest_child_index.?];
                    self.tree.items[lowest_child_index.?] = temp;
                } else {
                    break;
                }

                current_index = lowest_child_index.?;
                left_child_index = current_index * 2 + 1;
                right_child_index = current_index * 2 + 2;
            }

            return result;
        }
    };
}

test "BinaryHeap" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var binary_heap = BinaryHeap(u32).init(allocator);
    defer binary_heap.deinit();

    try binary_heap.push(5);
    try binary_heap.push(6);
    try binary_heap.push(4);
    try binary_heap.push(2);
    try binary_heap.push(7);
    try binary_heap.push(3);
    try binary_heap.push(1);

    std.debug.print("{?d}\n", .{binary_heap.pop()});
    std.debug.print("{?d}\n", .{binary_heap.pop()});
    std.debug.print("{?d}\n", .{binary_heap.pop()});
    std.debug.print("{?d}\n", .{binary_heap.pop()});
    std.debug.print("{?d}\n", .{binary_heap.pop()});
    std.debug.print("{?d}\n", .{binary_heap.pop()});
    std.debug.print("{?d}\n", .{binary_heap.pop()});
    std.debug.print("{?d}\n", .{binary_heap.pop()});
}
