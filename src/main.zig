const std = @import("std");
const testing = std.testing;

fn equil(comptime S: type) S {
    return switch (@typeInfo(S)) {
        .Int => |info| switch (info.signedness) {
            .signed => 0,
            .unsigned => (1 << (info.bits - 1)),
        },
        .Float => 0.0,
        else => @compileError("unsupported sample type"),
    };
}

test "equilibrium samples" {
    inline for (1..129) |i| {
        const ti = std.builtin.Type{ .Int = std.builtin.Type.Int{
            .bits = i,
            .signedness = .signed,
        } };
        try testing.expectEqual(equil(@Type(ti)), 0);

        const tu = std.builtin.Type{ .Int = std.builtin.Type.Int{
            .bits = i,
            .signedness = .unsigned,
        } };
        try testing.expectEqual(equil(@Type(tu)), (1 << (i - 1)));
    }

    try testing.expectEqual(equil(f16), 0.0);
    try testing.expectEqual(equil(f32), 0.0);
    try testing.expectEqual(equil(f64), 0.0);
}
