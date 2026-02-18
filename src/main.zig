const std = @import("std");
const vm = @import("vm.zig");
const insts = @import("insts.zig");

const loadk = insts.loadk;
const add = insts.add;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const bytecode = [_]u64{
        loadk(0, 42),
        loadk(1, 84),
        add(0, 1, 0),
    };

    var machine: vm.VM = try .init(allocator, &bytecode);
    const result = try machine.run();

    std.debug.print("result = {}", .{result});
}
