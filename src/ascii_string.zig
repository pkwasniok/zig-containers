const std = @import("std");

pub const ASCIIStringError = error{
    IndexOutOfBounds,
};

pub const ASCIIString = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    buffer: []u8,
    string: []u8,

    // Initialize
    //
    // This function initializes the string but doesn't allocate any memory.
    //
    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .allocator = allocator,
            .buffer = &.{},
            .string = &.{},
        };
    }

    // Deinitialize
    //
    // This function deinitializes the string by freeing all of the allocated memory
    // and reseting the pointers.
    //
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

    // Grow
    //
    // This function increases capacity of the string by specified amount.
    //
    pub fn grow(self: *Self, n: usize) !void {
        self.buffer = try self.allocator.realloc(self.buffer, self.buffer.len + n);
        self.string = self.buffer[0..self.string.len];
    }

    // Grow to capacity
    //
    // This function increases capacity of the string to be equal to specified amount.
    //
    pub fn growTo(self: *Self, n: usize) !void {
        if (self.buffer.len < n) {
            try self.grow(n - self.buffer.len);
        }
    }

    // Shrink
    //
    // This function reduces capacity of the string by specified amount.
    //
    pub fn shrink(self: *Self, n: usize) !void {
        self.buffer = try self.allocator.realloc(self.buffer, self.buffer.len - n);
        self.string = self.buffer[0..self.string.len];
    }

    // Shrink to capacity
    //
    // This function reduces capacity of the string to be equal to specified amount.
    //
    pub fn shrinkTo(self: *Self, n: usize) !void {
        // TODO
        _ = self;
        _ = n;
    }

    // Shrink to fit
    //
    // This function reduces capacity of the string to be equal to it's length.
    //
    pub fn shrinkToFit(self: *Self) void {
        // TODO
        _ = self;
    }

    // Return length
    //
    // This funtion returns length of the string, in terms of characters.
    //
    pub fn length(self: *Self) usize {
        return self.string.len;
    }

    // Return capacity
    //
    // This function returns the size of allocated memory, in terms of characters.
    // The capacity is always equal or greater than length of the string, so it
    // is not the same as length of the string.
    //
    pub fn capacity(self: *Self) usize {
        return self.buffer.len;
    }

    // Append character to string
    //
    // This function appends single character to the end.
    //
    pub fn push(self: *Self, char: u8) !void {
        try self.grow_to(self.string.len + 1);

        self.buffer[self.string.len] = char;
        self.string = self.buffer[0 .. self.string.len + 1];
    }

    // Append to string
    //
    // This function appends string to the end.
    //
    pub fn pushString(self: *Self, string: []const u8) !void {
        try self.grow_to(self.string.len + string.len);

        for (string, 0..) |char, index| {
            self.buffer[self.string.len + index] = char;
        }

        self.string = self.buffer[0 .. self.string.len + string.len];
    }

    // Remove last character
    //
    // This function removes single character from the end.
    //
    pub fn pop(self: *Self) ?u8 {
        if (self.string.len == 0) {
            return null;
        }

        const char = self.string[self.string.len - 1];
        self.string = self.buffer[0 .. self.string.len - 1];
        return char;
    }

    // Remove last characters
    //
    // This function removes characters from the end.
    //
    pub fn popString(self: *Self, len: usize) void {
        if (len > self.string.len) {
            self.string = &.{};
            return;
        }

        self.string = self.buffer[0 .. self.string.len - len];
    }

    // Insert character into string
    //
    // This function inserts character at specified index.
    //
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

    // Insert into string
    //
    // This function inserts string at specified index.
    //
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

    // Remove character from string
    //
    // This function removes single character at specified index.
    //
    pub fn remove(self: *Self, index: usize) !void {
        if (index >= self.string.len) {
            return ASCIIStringError.IndexOutOfBounds;
        }

        for (index..self.string.len - 1) |i| {
            self.buffer[i] = self.buffer[i + 1];
        }

        self.string = self.buffer[0 .. self.string.len - 1];
    }

    // Remove from string
    //
    // This function removes substring at specified index.
    //
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

    // Replace chracter
    //
    // This function replaces single character at specified index.
    //
    pub fn replace(self: *Self, index: usize, char: u8) !void {
        if (index >= self.string.len) {
            return ASCIIStringError.IndexOutOfBounds;
        }

        self.buffer[index] = char;
    }

    // Replace string
    //
    // This function replaces substring at specified index.
    //
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

    // Clear string
    //
    // This function removes all characters but doesn't free any of the
    // allocated memory.
    //
    pub fn clear(self: *Self) void {
        self.string = self.buffer[0..0];
    }

    // Remove whitespace characters from the front
    //
    // This function removes all whitespace characters from the front.
    //
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

    // Remove whitespace characters from the end
    //
    // This function removes all whitespace characters from the end.
    //
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

    // Remove whitespace characters
    //
    // This function removes all whitespace characters.
    //
    pub fn trim(self: *Self) !void {
        try self.trimFront();
        try self.trimEnd();
    }

    pub fn toLowercase(self: *Self) void {
        // TODO
        _ = self;
    }

    pub fn toUppercase(self: *Self) void {
        // TODO
        _ = self;
    }

    // Check if starts with specified substring
    pub fn startsWith(self: *Self, string: []const u8) bool {
        return std.mem.startsWith(u8, self.string, string);
    }

    // Check if ends with specified substring
    pub fn endsWith(self: *Self, string: []const u8) bool {
        return std.mem.endsWith(u8, self.string, string);
    }

    // Get index of first occurence of specified substring
    // Deprecated
    pub fn indexOf(self: *Self, string: []const u8) ?usize {
        // TODO: Delete
        return std.mem.indexOf(u8, self.string, string);
    }

    // Find first occurence of substring.
    //
    // This function finds the first occurence of a substring and returns it's index.
    //
    pub fn findFirst(self: *Self, needle: []const u8) ?usize {
        // TODO
        _ = self;
        _ = needle;
    }

    // Find last occurence of substring.
    //
    // This function finds the last occurence of a substring and returns it's index.
    //
    pub fn findLast(self: *Self, needle: []const u8) ?usize {
        // TODO
        _ = self;
        _ = needle;
    }

    // Find first occurence of substring, starting from specified index.
    //
    // This function finds the firs occurence of a substring after specified
    // index and returns it's index.
    //
    pub fn findFrom(self: *Self, index: usize, needle: []const u8) ?usize {
        // TODO
        _ = self;
        _ = index;
        _ = needle;
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
