const std = @import("std");
const vmcore = @import("vm/core.zig");
const Lexer = @import("compiler/lexer.zig").Lexer;
const Parser = @import("compiler/parser.zig").Parser;
const insts = @import("vm/instructions.zig");
const compiler = @import("compiler/codegen.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const source =
        \\%0 = loadk 42
        \\%1 = loadk 84
        \\%3 = add %0, %1
        \\print %3
        \\halt
    ;

    var parser = try Parser.init(allocator, source);
    const ast = try parser.parse();

    for (ast, 0..) |n, i| {
        std.debug.print("[{d}]: ", .{i});
        switch (n) {
            .loadk => |l| std.debug.print("LOADK {} [{}]\n", .{ l.dest, l.imm }),
            .binary_op => |b| std.debug.print("BINOP {s} {} {} [{}]\n", .{ @tagName(b.op), b.lhs, b.rhs, b.dest }),
            .print => |p| std.debug.print("PRINT [{}]\n", .{p.reg}),
            .halt => std.debug.print("HALT\n", .{}),
        }
    }

    var codegen = compiler.CodeGen.init(allocator, ast);
    const bytecode = try codegen.generate();

    var vm = try vmcore.VM.init(allocator, bytecode);
    _ = try vm.run();

    // std.debug.print("{d}\n", .{result});
}
