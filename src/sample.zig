const std = @import("std");
const testing = std.testing;

fn eq(comptime S: type) S {
    return comptime switch (@typeInfo(S)) {
        .Int => |info| switch (info.signedness) {
            .signed => 0,
            .unsigned => if (info.bits > 0) (1 << (info.bits - 1)) else 0,
        },
        .Float => 0.0,
        else => @compileError("unsupported sample type: " ++ @typeName(S)),
    };
}

test "equilibrium samples" {
    inline for (1..129) |b| {
        const ib = std.builtin.Type{ .Int = std.builtin.Type.Int{
            .bits = b,
            .signedness = .signed,
        } };
        try testing.expectEqual(eq(@Type(ib)), 0);

        const ub = std.builtin.Type{ .Int = std.builtin.Type.Int{
            .bits = b,
            .signedness = .unsigned,
        } };
        try testing.expectEqual(eq(@Type(ub)), (1 << (b - 1)));
    }

    try testing.expectEqual(eq(f16), 0.0);
    try testing.expectEqual(eq(f32), 0.0);
    try testing.expectEqual(eq(f64), 0.0);
    // try testing.expectEqual(eq(bool), true);
}
