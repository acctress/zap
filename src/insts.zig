pub const Instruction = packed union {
    pub const Op = enum(u8) {
        loadk = 1,
        add = 2,
    };

    bits: u64,

    loadk: packed struct { op: Op, dest_reg: u8, constant: i32, _padding: u16 = 0 },

    /// "lhs_reg" is the left hand side register of the expression, vice versa.
    add: packed struct { op: Op, lhs_reg: u8, rhs_reg: u8, result_reg: u8, _padding: u8 = 0 },
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
        .add = .{ .op = .add, .lhs_reg = lhs_reg, .rhs_reg = rhs_reg, .result_reg = result_reg, ._padding = 0 },
    };

    return i.bits;
}
