const std = @import("std");
const testing = std.testing;

fn eq_s(comptime S: type) S {
    return comptime switch (@typeInfo(S)) {
        .Int => |info| switch (info.signedness) {
            .signed => 0,
            .unsigned => if (info.bits > 0) (1 << (info.bits - 1)) else 0,
        },
        .Float => 0.0,
        else => @compileError("unsupported sample type: " ++ @typeName(S)),
    };
}

fn eq_f(comptime F: type) F {
    return comptime switch (@typeInfo(F)) {
        .Int => eq_s(F),
        .Float => eq_s(F),
        .Array => |info| if (info.sentinel != null) @compileError("unsupported frame type: " ++ @typeName(F)) else [1](info.child){eq_s(info.child)} ** info.len,
        .Vector => |info| @as(@Vector(info.len, info.child), @splat(eq_s(info.child))),
        else => @compileError("unsupported frame type: " ++ @typeName(F)),
    };
}

test "equilibrium samples" {
    inline for (1..129) |b| {
        const ib = std.builtin.Type{ .Int = std.builtin.Type.Int{
            .bits = b,
            .signedness = .signed,
        } };
        try testing.expectEqual(eq_s(@Type(ib)), 0);

        const ub = std.builtin.Type{ .Int = std.builtin.Type.Int{
            .bits = b,
            .signedness = .unsigned,
        } };
        try testing.expectEqual(eq_s(@Type(ub)), (1 << (b - 1)));
    }

    try testing.expectEqual(eq_s(f16), 0.0);
    try testing.expectEqual(eq_s(f32), 0.0);
    try testing.expectEqual(eq_s(f64), 0.0);
    // try testing.expectEqual(eq_s(bool), true);
    try testing.expectEqual(eq_f([8]i8), .{ 0, 0, 0, 0, 0, 0, 0, 0 });
    // try testing.expectEqual(eq_f([8:0]i8), .{ 0, 0, 0, 0, 0, 0, 0, 0 });

    try testing.expectEqual(eq_f(@Vector(3, i5)), .{ 0, 0, 0 });
    // try testing.expectEqual(eq_f(@Vector(3, bool)), .{ false, false, false });
}
