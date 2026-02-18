const std = @import("std");
const insts = @import("insts.zig");

pub const VM = struct {
    allocator: std.mem.Allocator,
    bytecode: []const u64,
    registers: []i32,
    pc: usize,

    pub fn init(allocator: std.mem.Allocator, bytecode: []const u64) !VM {
        const registers = try allocator.alloc(i32, 256);

        return .{
            .allocator = allocator,
            .bytecode = bytecode,
            .registers = registers,
            .pc = 0,
        };
    }

    pub fn run(self: *VM) !i64 {
        while (self.pc < self.bytecode.len) {
            self.execute(self.bytecode[self.pc]);
            self.pc += 1;
        }

        return self.registers[0];
    }

    fn execute(self: *VM, bits: u64) void {
        const inst = insts.Instruction{ .bits = bits };
        switch (insts.get_op(inst)) {
            .loadk => {
                const loadk = inst.loadk;
                self.registers[loadk.dest_reg] = loadk.constant;
                std.debug.print("[debug!] loaded constant {} into register {}\n", .{ loadk.constant, loadk.dest_reg });
            },

            .add => {
                const add = inst.add;
                self.registers[add.result_reg] = self.get_reg(add.lhs_reg) + self.get_reg(add.rhs_reg);
                std.debug.print("[debug!] added register {} and {} into register {}\n", .{ add.lhs_reg, add.rhs_reg, add.result_reg });
            },
        }
    }

    fn get_reg(self: *VM, idx: u8) i32 {
        return self.registers[idx];
    }
};
