pub const Instruction = packed union {
    bits: u64,
    loadk: packed struct { op: Op, dest_reg: u8, constant: i32, _padding: u16 },
    arithmetic: packed struct { op: Op, lhs_reg: u8, rhs_reg: u8, result_reg: u8, _padding: u32 },
    mov: packed struct { op: Op, src_reg: u8, dest_reg: u8, _padding: u40 },
    single: packed struct { op: Op, reg: u8, _padding: u48 },
    control: packed struct { op: Op, _padding: u56 },

    pub const Op = enum(u8) {
        loadk = 1,
        add = 2,
        sub = 3,
        mov = 4,
        print = 5,
        halt = 6,
    };
};

pub fn unpack(bits: u64) Instruction {
    return @bitCast(bits);
}

pub fn get_op(inst: Instruction) Instruction.Op {
    return @enumFromInt(@as(u8, @truncate(inst.bits)));
}

pub fn loadk(dest_reg: u8, constant: i32) u64 {
    const i: Instruction = .{
        .loadk = .{ .op = .loadk, .dest_reg = dest_reg, .constant = constant, ._padding = 0 },
    };

    return i.bits;
}

pub fn add(lhs_reg: u8, rhs_reg: u8, result_reg: u8) u64 {
    const i: Instruction = .{
        .arithmetic = .{ .op = .add, .lhs_reg = lhs_reg, .rhs_reg = rhs_reg, .result_reg = result_reg, ._padding = 0 },
    };

    return i.bits;
}

pub fn sub(lhs_reg: u8, rhs_reg: u8, result_reg: u8) u64 {
    const i: Instruction = .{
        .arithmetic = .{ .op = .sub, .lhs_reg = lhs_reg, .rhs_reg = rhs_reg, .result_reg = result_reg, ._padding = 0 },
    };

    return i.bits;
}

pub fn mov(src_reg: u8, dest_reg: u8) u64 {
    const i: Instruction = .{
        .mov = .{ .op = .mov, .src_reg = src_reg, .dest_reg = dest_reg, ._padding = 0 },
    };

    return i.bits;
}

pub fn print(reg: u8) u64 {
    const i: Instruction = .{
        .single = .{ .op = .print, .reg = reg, ._padding = 0 },
    };

    return i.bits;
}

pub fn halt() u64 {
    const i: Instruction = .{ .control = .{ .op = .halt, ._padding = 0 } };
    return i.bits;
}
