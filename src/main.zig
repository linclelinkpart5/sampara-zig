const std = @import("std");
const testing = std.testing;

fn try_equil(comptime S: type) !S {
    return comptime switch (@typeInfo(S)) {
        .Int => |info| switch (info.signedness) {
            .signed => 0,
            .unsigned => (1 << (info.bits - 1)),
        },
        .Float => 0.0,
        else => error.InvalidSampleType,
    };
}

fn equil(comptime S: type) S {
    return comptime try_equil(S) catch |err| switch (err) {
        error.InvalidSampleType => @compileError("unsupported sample type: " ++ @typeName(S)),
    };
}

test "equilibrium samples" {
    inline for (1..129) |b| {
        const ib = std.builtin.Type{ .Int = std.builtin.Type.Int{
            .bits = b,
            .signedness = .signed,
        } };
        try testing.expectEqual(equil(@Type(ib)), 0);

        const ub = std.builtin.Type{ .Int = std.builtin.Type.Int{
            .bits = b,
            .signedness = .unsigned,
        } };
        try testing.expectEqual(equil(@Type(ub)), (1 << (b - 1)));
    }

    try testing.expectEqual(equil(f16), 0.0);
    try testing.expectEqual(equil(f32), 0.0);
    try testing.expectEqual(equil(f64), 0.0);
    // try testing.expectEqual(equil(bool), true);
    // try testing.expectEqual(equil([8]i8), .{ 0, 0, 0, 0, 0, 0, 0, 0 });
}
