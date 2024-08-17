const std = @import("std");

pub fn DoublyLinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        const Node = struct {
            value: T,
            prev: *?Node,
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
            _ = self;
        }

        pub fn push_front(self: *Self) void {
            _ = self;
        }

        pub fn push_back(self: *Self) void {
            _ = self;
        }

        pub fn pop_front(self: Self) void {
            _ = self;
        }

        pub fn pop_back(self: Self) void {
            _ = self;
        }
    };
}

test "DoublyLinkedList" {}
