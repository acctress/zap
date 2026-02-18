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

    const args = try std.process.argsAlloc(allocator);

    if (args.len > 2) {
        std.debug.print("too many args, expected one.\n", .{});
        std.process.exit(1);
    }

    const source_path = args[1];
    var source_file = try std.fs.cwd().openFile(source_path, .{ .mode = .read_only });
    defer source_file.close();

    const source: []u8 = try source_file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(source);

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
}
