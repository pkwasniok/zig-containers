const std = @import("std");

pub fn ArrayList(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        buffer: ?[]T,
        items: ?[]T,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .allocator = allocator,
                .buffer = null,
                .items = null,
            };
        }

        pub fn deinit(self: *Self) void {
            if (self.buffer) |buffer| {
                self.allocator.free(buffer);
            }

            self.buffer = null;
            self.items = null;
        }

        pub fn grow(self: *Self, n: usize) !void {
            if (self.buffer) |buffer| {
                self.buffer = try self.allocator.realloc(buffer, buffer.len + n);

                if (self.items) |items| {
                    self.items = buffer[0..items.len];
                }
            } else {
                self.buffer = try self.allocator.alloc(T, n);
                self.items = self.buffer.?[0..0];
            }
        }

        fn shrink(self: *Self, size: usize) void {
            _ = self;
            _ = size;
        }

        pub fn push(self: *Self, item: T) !void {
            // Buffer not initialized
            if (self.buffer == null) {
                try self.grow(8);
            }

            // Buffer out of space
            if (self.items.?.len + 1 >= self.buffer.?.len) {
                try self.grow(self.buffer.?.len * 2);
            }

            // Default case
            self.buffer.?[self.items.?.len] = item;
            self.items = self.buffer.?[0 .. self.items.?.len + 1];
        }

        pub fn pop(self: *Self) ?T {
            if (self.items) |items| {
                if (items.len > 0) {
                    const item = items[items.len - 1];
                    self.items = self.items.?[0 .. items.len - 1];
                    return item;
                }

                return null;
            }

            return null;
        }

        pub fn len(self: *Self) usize {
            if (self.items) |items| {
                return items.len;
            }

            return 0;
        }

        pub fn get(self: *Self, index: usize) ?T {
            if (self.items) |items| {
                if (items.len - 1 >= index) {
                    return items[index];
                }

                return null;
            }

            return null;
        }
    };
}

test "ArrayList" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var array_list = ArrayList(usize).init(allocator);
    defer array_list.deinit();

    for (0..128) |i| {
        try array_list.push(i);
    }

    var j: usize = 128;
    while (array_list.pop()) |i| {
        j -= 1;
        try std.testing.expect(i == j);
    }

    try std.testing.expect(array_list.pop() == null);
}

test "ArrayList deinit" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var array_list = ArrayList(usize).init(allocator);
    defer array_list.deinit();

    try array_list.push(1);
    try array_list.push(2);
    try array_list.push(3);
}

test "ArrayList get" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var array_list = ArrayList(usize).init(allocator);
    defer array_list.deinit();

    try array_list.push(1);
    try array_list.push(2);
    try array_list.push(3);

    try std.testing.expect(array_list.get(0) == 1);
    try std.testing.expect(array_list.get(1) == 2);
    try std.testing.expect(array_list.get(2) == 3);

    try std.testing.expect(array_list.get(3) == null);
}
