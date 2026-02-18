const std = @import("std");
const insts = @import("instructions.zig");

pub const VM = struct {
    allocator: std.mem.Allocator,
    bytecode: []const u64,
    registers: []i32,
    pc: usize,
    do_halt: bool,

    pub fn init(allocator: std.mem.Allocator, bytecode: []const u64) !VM {
        const registers = try allocator.alloc(i32, 256);

        return .{
            .allocator = allocator,
            .bytecode = bytecode,
            .registers = registers,
            .do_halt = false,
            .pc = 0,
        };
    }

    pub fn run(self: *VM) !i64 {
        var stdout_buf: [1024]u8 = undefined;
        var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
        const stdout: *std.io.Writer = &stdout_writer.interface;

        while (!self.do_halt) {
            try self.execute(self.bytecode[self.pc], stdout);
            self.pc += 1;
        }

        try stdout.flush();
        return self.registers[0];
    }

    fn execute(self: *VM, bits: u64, stdout: anytype) !void {
        const inst = insts.Instruction{ .bits = bits };
        switch (insts.get_op(inst)) {
            .loadk => {
                const i = inst.loadk;
                self.registers[i.dest_reg] = i.constant;
            },

            .add => {
                const i = inst.arithmetic;
                self.registers[i.result_reg] = self.get_reg(i.lhs_reg) + self.get_reg(i.rhs_reg);
            },

            .sub => {
                const i = inst.arithmetic;
                self.registers[i.result_reg] = self.get_reg(i.lhs_reg) - self.get_reg(i.rhs_reg);
            },

            .mov => {
                const i = inst.mov;
                self.registers[i.dest_reg] = self.get_reg(i.src_reg);
            },

            .print => {
                const i = inst.single;
                const reg_value = self.get_reg(i.reg);
                try stdout.print("{d}\n", .{reg_value});
            },

            .halt => {
                self.do_halt = true;
            },
        }
    }

    fn get_reg(self: *VM, idx: u8) i32 {
        return self.registers[idx];
    }
};
