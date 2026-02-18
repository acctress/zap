//! Minimal and purpose-built lexer for Zap's SSA
const std = @import("std");

pub const Token = union(enum) {
    op_loadk,
    op_add,
    op_sub,
    op_print,
    op_halt,

    register: u8,
    identifier: []const u8,

    integer: i32,
    equal,
    comma,
    newline,
    eof,
};

pub const Lexer = struct {
    source: []const u8,
    pos: usize,

    pub fn init(source: []const u8) Lexer {
        return .{ .source = source, .pos = 0 };
    }

    pub fn next(self: *Lexer) !Token {
        while (self.pos < self.source.len) {
            const c = self.source[self.pos];
            if (c == ' ' or c == '\t' or c == '\r') {
                self.pos += 1;
            } else {
                break;
            }
        }

        if (self.pos >= self.source.len) return .eof;

        const current = self.source[self.pos];

        switch (current) {
            '=' => {
                self.pos += 1;
                return .equal;
            },
            ',' => {
                self.pos += 1;
                return .comma;
            },
            '\n' => {
                self.pos += 1;
                return .newline;
            },
            else => {
                if (std.ascii.isDigit(current)) {
                    const start = self.pos;
                    while (self.pos < self.source.len and std.ascii.isDigit(self.source[self.pos])) {
                        self.pos += 1;
                    }
                    return .{ .integer = try std.fmt.parseInt(i32, self.source[start..self.pos], 10) };
                }

                if (current == '%') {
                    self.pos += 1;

                    const start = self.pos;
                    while (self.pos < self.source.len and std.ascii.isDigit(self.source[self.pos])) {
                        self.pos += 1;
                    }
                    return .{ .register = try std.fmt.parseInt(u8, self.source[start..self.pos], 10) };
                }

                if (std.ascii.isAlphabetic(current)) {
                    const start = self.pos;
                    while (self.pos < self.source.len and std.ascii.isAlphabetic(self.source[self.pos])) {
                        self.pos += 1;
                    }

                    if (std.mem.eql(u8, self.source[start..self.pos], "loadk")) {
                        return .op_loadk;
                    }

                    if (std.mem.eql(u8, self.source[start..self.pos], "add")) {
                        return .op_add;
                    }

                    if (std.mem.eql(u8, self.source[start..self.pos], "sub")) {
                        return .op_sub;
                    }

                    if (std.mem.eql(u8, self.source[start..self.pos], "print")) {
                        return .op_print;
                    }

                    if (std.mem.eql(u8, self.source[start..self.pos], "halt")) {
                        return .op_halt;
                    }
                }

                self.pos += 1;
                return self.next();
            },
        }
    }
};
