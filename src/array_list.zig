const std = @import("std");

pub fn ArrayList(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        buffer: []T,
        items: []T,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .allocator = allocator,
                .buffer = &[_]T{},
                .items = &[_]T{},
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.buffer);
        }

        pub fn grow(self: *Self, capacity: usize) !void {
            const new_buffer_size = self.buffer.len + capacity;
            self.buffer = try self.allocator.realloc(self.buffer, new_buffer_size);
        }

        pub fn shrink(self: *Self, capacity: usize) !void {
            const new_buffer_size = self.buffer.len - capacity;
            self.buffer = try self.allocator.realloc(self.buffer, new_buffer_size);
        }

        pub fn push_front(self: *Self, item: T) !void {
            if (self.buffer.len < self.items.len + 1) {
                try self.grow((self.buffer.len + 1) * 2);
            }

            self.buffer[self.items.len] = item;
            self.items = self.buffer[0 .. self.items.len + 1];
        }

        pub fn pop_front(self: *Self) ?T {
            if (self.items.len == 0) {
                return null;
            }

            self.items = self.buffer[0 .. self.items.len - 1];
            return self.buffer[self.items.len];
        }

        pub fn get(self: *Self, index: usize) ?T {
            if (index >= self.items.len) {
                return null;
            }

            return self.buffer[index];
        }
    };
}

test "ArrayList" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var array_list = ArrayList(u32).init(allocator);
    defer array_list.deinit();

    try array_list.push_front(1);
    try array_list.push_front(2);
    try array_list.push_front(3);
    try array_list.push_front(4);
    try array_list.push_front(5);

    try std.testing.expect(array_list.get(2) == 3);
    try std.testing.expect(array_list.get(10) == null);

    try std.testing.expect(array_list.pop_front() == 5);
    try std.testing.expect(array_list.pop_front() == 4);
    try std.testing.expect(array_list.pop_front() == 3);
    try std.testing.expect(array_list.pop_front() == 2);
    try std.testing.expect(array_list.pop_front() == 1);
    try std.testing.expect(array_list.pop_front() == null);
}
