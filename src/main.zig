const std = @import("std");
const infinity = @import("can_i_be_infinity");
const fps = @import("fps.zig");
const allocator_selector = @import("allocator.zig");
const actions = @import("cli/actions.zig");

pub fn main() !void {
    // Initialization
    const allocator_info = allocator_selector.getAllocator();
    const allocator = allocator_info.allocator;

    defer if (allocator_info.is_debug) {
        switch (allocator_selector.debugDeinit()) {
            .leak => std.log.debug("You leaked memory dum dum", .{}),
            .ok => std.log.debug("No memory leaks. For now...", .{}),
        }
    };

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    const name = args.next();
    const command = args.next();

    try run(command, name.?, allocator);
}

fn run(command: ?[]const u8, binary_name: []const u8, allocator: std.mem.Allocator) !void {
    try actions.init(allocator, binary_name);
    defer actions.deinit(allocator);
    actions.execute(command, allocator) catch |err| switch (err) {
        actions.Error.command_not_found => {
            std.log.err("Command not found: {s}", .{command.?});

            // TODO: This will probably be removed later
            try actions.execute("help", allocator);
        },

        else => return err
    };
}
