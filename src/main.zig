const std = @import("std");
const infinity = @import("can_i_be_infinity");
const fps = @import("fps.zig");
const allocator_selector = @import("allocator.zig");

pub fn main() !void {
    var timer: std.time.Timer = try .start();
    var fps_info: fps.FpsInfo = .{.delta = 0, .fps = 0, .fps_average = 0};

    const allocator_info = allocator_selector.getAllocator();
    const allocator = allocator_info.allocator;

    defer if (allocator_info.is_debug) {
        switch (allocator_selector.debugDeinit()) {
            .leak => std.debug.print("You leaked memory dum dum\n", .{}),
            .ok => std.debug.print("No memory leaks. For now...\n", .{}),
        }
    };

    const buff = try allocator.alloc(u8, 1024);
    defer allocator.free(buff);

    var writer = std.fs.File.stdout().writer(buff);

    while (true) {
        fps.frameStart(&timer);

        try tick(fps_info.delta, fps_info.fps, &writer.interface);

        fps_info = fps.frameEnd(&timer);
    }
}

fn tick(delta: f32, frame: u32, writer: *std.Io.Writer) !void {
    try writer.print("Frame: {d}, delta: {d}\n", .{frame, delta});

    try writer.flush();
}
