const std = @import("std");
const ArrayList = std.ArrayList;

const compiler_lexer = @import("lexer.zig");
const Token = compiler_lexer.Token;
const Lexer = compiler_lexer.Lexer;

/// This represents either "%42" or "42".
/// Any integer prefixed with '%' notates a register.
pub const Operand = union(enum) {
    register: u8,
    immediate: i32,
};

pub const BinOp = enum { add, sub, mul, div };

pub const Node = union(enum) {
    /// %0 = loadk 23
    /// This loads the immediate 23 into the 0 register
    loadk: struct {
        dest: u8,
        imm: i32,
    },

    /// %0 = add %0, %1
    /// Any binary operation with two operands
    binary_op: struct {
        op: BinOp,
        dest: u8,
        lhs: u8,
        rhs: u8,
    },

    /// print %2
    /// A special print function call
    print: struct { reg: u8 },

    halt: void,
};

pub const Parser = struct {
    allocator: std.mem.Allocator,
    ast: ArrayList(Node),
    lexer: Lexer,
    current: Token,

    pub fn init(allocator: std.mem.Allocator, source: []const u8) !Parser {
        var self: Parser = .{
            .allocator = allocator,
            .ast = .empty,
            .lexer = Lexer.init(source),
            .current = undefined,
        };

        self.current = try self.lexer.next();
        return self;
    }

    pub fn deinit(self: *Parser) void {
        self.ast.deinit(self.allocator);
    }

    pub fn parse(self: *Parser) ![]Node {
        while (self.current != .eof) {
            if (self.current == .newline) {
                _ = try self.advance();
                continue;
            }

            const n = try self.parse_statement();
            try self.ast.append(self.allocator, n);
        }

        return self.ast.toOwnedSlice(self.allocator);
    }

    fn parse_statement(self: *Parser) !Node {
        return switch (self.current) {
            .register => self.parse_assignment(),
            .op_print => self.parse_call(),
            .op_halt => {
                _ = try self.advance();
                return .halt;
            },

            else => {
                std.debug.print("unexpected token at start of line '{s}'\n", .{@tagName(self.current)});
                return error.InvalidSyntax;
            },
        };
    }

    fn parse_call(self: *Parser) !Node {
        return switch (self.current) {
            .op_print => {
                _ = try self.advance();
                const reg = try self.expect(.register);
                return .{ .print = .{ .reg = reg.register } };
            },

            else => error.UnexpectedCall,
        };
    }

    fn parse_assignment(self: *Parser) !Node {
        const dest_reg_t = try self.expect(.register);
        const dest_value = dest_reg_t.register;

        _ = try self.expect(.equal);

        const op_t = self.current;
        return switch (op_t) {
            .op_loadk => {
                _ = try self.advance();
                const imm = try self.expect(.integer);
                return Node{ .loadk = .{ .dest = dest_value, .imm = imm.integer } };
            },

            .op_add, .op_sub => {
                const op = if (op_t == .op_add) BinOp.add else BinOp.sub;
                _ = try self.advance();

                const lhs = (try self.expect(.register)).register;
                _ = try self.expect(.comma);

                const rhs = (try self.expect(.register)).register;
                return Node{ .binary_op = .{ .op = op, .lhs = lhs, .rhs = rhs, .dest = dest_value } };
            },

            else => error.UnexpectedOpcode,
        };
    }

    fn advance(self: *Parser) !Token {
        const p = self.current;
        self.current = try self.lexer.next();
        return p;
    }

    fn expect(self: *Parser, expected_tag_type: std.meta.Tag(Token)) !Token {
        if (self.current != expected_tag_type) {
            std.debug.print("expected {s}, got {s} instead", .{ @tagName(expected_tag_type), @tagName(self.current) });
            return error.UnexpectedToken;
        }

        return self.advance();
    }

    fn consume(self: *Parser) void {
        if (self.current.? == .eof) {
            std.debug.print("unexpected eof");
            std.process.exit(1);
        }

        self.current = self.lexer.next();
    }
};
