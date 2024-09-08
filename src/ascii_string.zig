const std = @import("std");

pub const ASCIIStringError = error{
    IndexOutOfBounds,
};

pub const ASCIIString = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    buffer: []u8,
    string: []u8,

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .allocator = allocator,
            .buffer = &.{},
            .string = &.{},
        };
    }

    pub fn deinit(self: *Self) void {
        if (self.buffer.len > 0) {
            self.allocator.free(self.buffer);
            self.string = &.{};
            self.buffer = &.{};
        }
    }

    pub fn format(self: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;

        try writer.print("{s}", .{self.string});
    }

    pub fn grow(self: *Self, n: usize) !void {
        self.buffer = try self.allocator.realloc(self.buffer, self.buffer.len + n);
        self.string = self.buffer[0..self.string.len];
    }

    pub fn grow_to(self: *Self, n: usize) !void {
        if (self.buffer.len < n) {
            try self.grow(n - self.buffer.len);
        }
    }

    pub fn shrink(self: *Self, n: usize) !void {
        self.buffer = try self.allocator.realloc(self.buffer, self.buffer.len - n);
        self.string = self.buffer[0..self.string.len];
    }

    pub fn length(self: *Self) usize {
        return self.string.len;
    }

    pub fn capacity(self: *Self) usize {
        return self.buffer.len;
    }

    pub fn push(self: *Self, char: u8) !void {
        try self.grow_to(self.string.len + 1);

        self.buffer[self.string.len] = char;
        self.string = self.buffer[0 .. self.string.len + 1];
    }

    pub fn pushString(self: *Self, string: []const u8) !void {
        try self.grow_to(self.string.len + string.len);

        for (string, 0..) |char, index| {
            self.buffer[self.string.len + index] = char;
        }

        self.string = self.buffer[0 .. self.string.len + string.len];
    }

    pub fn pop(self: *Self) ?u8 {
        if (self.string.len == 0) {
            return null;
        }

        const char = self.string[self.string.len - 1];
        self.string = self.buffer[0 .. self.string.len - 1];
        return char;
    }

    pub fn popString(self: *Self, len: usize) void {
        if (len > self.string.len) {
            self.string = &.{};
            return;
        }

        self.string = self.buffer[0 .. self.string.len - len];
    }

    pub fn insert(self: *Self, index: usize, char: u8) !void {
        if (index >= self.string.len) {
            return ASCIIStringError.IndexOutOfBounds;
        }

        try self.grow_to(self.string.len + 1);

        for (0..self.string.len - index) |i| {
            self.buffer[self.string.len - i] = self.buffer[self.string.len - i - 1];
        }

        self.string[index] = char;
        self.string = self.buffer[0 .. self.string.len + 1];
    }

    pub fn insertString(self: *Self, index: usize, string: []const u8) !void {
        if (index >= self.string.len) {
            return ASCIIStringError.IndexOutOfBounds;
        }

        try self.grow_to(self.string.len + string.len);

        for (0..self.string.len - index) |i| {
            self.buffer[self.string.len + string.len - i - 1] = self.buffer[self.string.len - i - 1];
        }

        for (string, 0..) |char, i| {
            self.buffer[index + i] = char;
        }

        self.string = self.buffer[0 .. self.string.len + string.len];
    }

    pub fn remove(self: *Self, index: usize) !void {
        if (index >= self.string.len) {
            return ASCIIStringError.IndexOutOfBounds;
        }

        for (index..self.string.len - 1) |i| {
            self.buffer[i] = self.buffer[i + 1];
        }

        self.string = self.buffer[0 .. self.string.len - 1];
    }

    pub fn removeString(self: *Self, index: usize, len: usize) !void {
        if (index >= self.string.len) {
            return ASCIIStringError.IndexOutOfBounds;
        }

        if (index + len >= self.string.len) {
            self.string = self.buffer[0..index];
            return;
        }

        for (0..self.string.len) |i| {
            if (index + i + len >= self.string.len) {
                break;
            }

            self.buffer[index + i] = self.buffer[index + i + len];
        }

        self.string = self.buffer[0 .. self.string.len - len];
    }

    pub fn replace(self: *Self, index: usize, char: u8) !void {
        if (index >= self.string.len) {
            return ASCIIStringError.IndexOutOfBounds;
        }

        self.buffer[index] = char;
    }

    pub fn replaceString(self: *Self, index: usize, string: []const u8) !void {
        if (index >= self.string.len) {
            return ASCIIStringError.IndexOutOfBounds;
        }

        try self.grow_to(index + string.len);

        for (string, 0..) |char, i| {
            self.buffer[index + i] = char;
        }

        if (self.string.len > index + string.len) {
            return;
        }

        self.string = self.buffer[0 .. index + string.len];
    }

    pub fn clear(self: *Self) void {
        self.string = self.buffer[0..0];
    }

    pub fn trimFront(self: *Self) !void {
        var len_to_trim: usize = 0;

        for (self.string) |char| {
            if (!std.ascii.isWhitespace(char)) {
                break;
            }

            len_to_trim += 1;
        }

        try self.removeString(0, len_to_trim);
    }

    pub fn trimEnd(self: *Self) !void {
        var len_to_trim: usize = 0;

        for (0..self.string.len) |i| {
            if (!std.ascii.isWhitespace(self.string[self.string.len - 1 - i])) {
                break;
            }

            len_to_trim += 1;
        }

        try self.removeString(self.string.len - len_to_trim, len_to_trim);
    }

    pub fn trim(self: *Self) !void {
        try self.trimFront();
        try self.trimEnd();
    }

    pub fn startsWith(self: *Self, string: []const u8) bool {
        return std.mem.startsWith(u8, self.string, string);
    }

    pub fn endsWith(self: *Self, string: []const u8) bool {
        return std.mem.endsWith(u8, self.string, string);
    }

    pub fn indexOf(self: *Self, string: []const u8) ?usize {
        return std.mem.indexOf(u8, self.string, string);
    }
};

test "ASCIIString init & deinit" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var string = ASCIIString.init(allocator);
    defer string.deinit();

    try string.pushString("A quick brown fox jumps over the lazy fox");
}

test "ASCIIString push, pop, length, capacity" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var string = ASCIIString.init(allocator);
    defer string.deinit();

    try string.pushString("A quick brown fox jumps over the lazy fox");

    try std.testing.expect(string.length() == 41);
    try std.testing.expect(string.capacity() == 41);

    string.popString(41);

    try std.testing.expect(string.length() == 0);
    try std.testing.expect(string.capacity() == 41);
}

test "ASCIIString insertString, removeString" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var string = ASCIIString.init(allocator);
    defer string.deinit();

    try string.pushString("A quick brown fox jumps over the lazy dog");

    try string.removeString(8, 6);

    try std.testing.expect(std.mem.eql(u8, string.string, "A quick fox jumps over the lazy dog"));

    try string.insertString(8, "black ");

    try std.testing.expect(std.mem.eql(u8, string.string, "A quick black fox jumps over the lazy dog"));
}

test "ASCIIString replaceString" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var string = ASCIIString.init(allocator);
    defer string.deinit();

    try string.pushString("A quick brown fox jumps over the lazy dog");

    try string.replaceString(8, "black");

    try std.testing.expect(std.mem.eql(u8, string.string, "A quick black fox jumps over the lazy dog"));
}

test "ASCIIString trim" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var string = ASCIIString.init(allocator);
    defer string.deinit();

    try string.pushString("     A quick brown fox jumps over the lazy dog     ");

    try string.trim();

    try std.testing.expect(std.mem.eql(u8, string.string, "A quick brown fox jumps over the lazy dog"));
}

test "ASCIIString indexOf, startsWith, endsWith" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var string = ASCIIString.init(allocator);
    defer string.deinit();

    try string.pushString("A quick brown fox jumps over the lazy dog");

    try std.testing.expect(string.startsWith("A quick"));
    try std.testing.expect(string.endsWith("lazy dog"));
    try std.testing.expect(string.indexOf("fox jumps") == 14);
}
