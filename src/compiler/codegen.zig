const std = @import("std");
const Node = @import("parser.zig").Node;
const insts = @import("../vm/instructions.zig");

pub const CodeGen = struct {
    allocator: std.mem.Allocator,
    nodes: []Node,
    bytecode: std.ArrayList(u64),

    pub fn init(allocator: std.mem.Allocator, nodes: []Node) CodeGen {
        return .{
            .allocator = allocator,
            .nodes = nodes,
            .bytecode = .empty,
        };
    }

    pub fn generate(self: *CodeGen) ![]u64 {
        for (self.nodes) |node| {
            const i = try self.generate_stmt(node);
            try self.bytecode.append(self.allocator, i);
        }

        return self.bytecode.toOwnedSlice(self.allocator);
    }

    fn generate_stmt(self: *CodeGen, node: Node) !u64 {
        _ = self;

        return switch (node) {
            .loadk => |l| {
                return insts.loadk(l.dest, l.imm);
            },

            .print => |p| {
                return insts.print(p.reg);
            },

            .binary_op => |b| switch (b.op) {
                .add => insts.add(b.lhs, b.rhs, b.dest),
                .sub => insts.sub(b.lhs, b.rhs, b.dest),
                .mul => insts.halt(),
                .div => insts.halt(),
            },

            else => insts.halt(),
        };
    }
};
