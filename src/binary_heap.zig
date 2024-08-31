const std = @import("std");
const ArrayList = @import("./array_list.zig").ArrayList;

//
// # Binary heap
//
// ## Memory layout
//
// It's binary tree represented as array
//
// ## Operations
//
// - `push`
//   Insert new elements onto heap. Time complexity: O(1).
// - `pop`
//   Remove lowest element from heap. Time complexity: O(log n).
//

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
            try self.tree.push(item);

            var current_index: usize = self.tree.len() - 1;
            var parent_index: usize = (current_index -| 1) / 2;

            while (self.tree.get(current_index).? < self.tree.get(parent_index).?) {
                const temp = self.tree.get(current_index).?;
                self.tree.items.?[current_index] = self.tree.get(parent_index).?;
                self.tree.items.?[parent_index] = temp;

                current_index = parent_index;
                parent_index = (current_index -| 1) / 2;
            }
        }

        pub fn pop(self: *Self) ?T {
            if (self.tree.len() == 0) {
                return null;
            }

            if (self.tree.len() == 1) {
                return self.tree.pop();
            }

            const result = self.tree.get(0).?;

            self.tree.items.?[0] = self.tree.pop().?;

            var current_index: usize = 0;
            var left_child_index: usize = current_index * 2 + 1;
            var right_child_index: usize = current_index * 2 + 2;

            while (true) {
                var lowest_child_index: ?usize = null;

                if (self.tree.len() >= right_child_index + 1 and self.tree.get(right_child_index).? < self.tree.get(left_child_index).?) {
                    lowest_child_index = right_child_index;
                } else if (self.tree.len() >= left_child_index + 1) {
                    lowest_child_index = left_child_index;
                }

                if (lowest_child_index == null) {
                    break;
                }

                if (self.tree.get(current_index).? > self.tree.get(lowest_child_index.?).?) {
                    const temp = self.tree.get(current_index).?;
                    self.tree.items.?[current_index] = self.tree.get(lowest_child_index.?).?;
                    self.tree.items.?[lowest_child_index.?] = temp;
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
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var binary_heap = BinaryHeap(usize).init(allocator);
    defer binary_heap.deinit();

    // Add items 127, 126, 125, ..., 0
    for (0..128) |item| {
        try binary_heap.push(127 - item);
    }

    // Check if items are retrieve in order 0, 1, 2, ..., 127
    var i: usize = 0;
    while (binary_heap.pop()) |item| {
        try std.testing.expect(item == i);
        i += 1;
    }
}

test "BinaryHeap deinit" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var binary_heap = BinaryHeap(u32).init(allocator);
    defer binary_heap.deinit();

    try binary_heap.push(1);
    try binary_heap.push(2);
    try binary_heap.push(3);
}
