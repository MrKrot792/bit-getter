const std = @import("std");
const infinity = @import("can_i_be_infinity");
const fps = @import("fps.zig");
const allocator_selector = @import("allocator.zig");
const actions = @import("actions.zig");

pub fn main() !void {
    // Initialization
    const allocator_info = allocator_selector.getAllocator();
    const allocator = allocator_info.allocator;

    defer if (allocator_info.is_debug) {
        switch (allocator_selector.debugDeinit()) {
            .leak => std.debug.print("You leaked memory dum dum\n", .{}),
            .ok => std.debug.print("No memory leaks. For now...\n", .{}),
        }
    };

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    const name = args.next();
    const command = args.next();

    var action: actions.Actions = .help;

    try actions.init(allocator);
    defer actions.deinit(allocator);
    action = try actions.actionByStringOrNull(command, allocator);

    try run(action, name.?);
}

fn run(action: actions.Actions, binary_name: []const u8) !void {
    // Setting some writing stuff
    var buff: [1024]u8 = undefined;
    var stdout_file = std.fs.File.stdout();
    var writer = stdout_file.writer(&buff);
    const stdout = &writer.interface;

    std.log.debug("Performing {t}.", .{action});

    var bits: f32 = 1321;

    switch (action) {
        .add_1  => bits += 1,
        .add_10 => bits += 10,
        .multiply_by_2  => bits *= 2,
        .help => {
            try stdout.print("Usage: {s} <COMMAND> <SUBCOMMAND> [VALUE]... \n", .{binary_name});
            try stdout.print("COMMANDs: \n", .{});
            try stdout.print("\tlb - list bits\n", .{});
            try stdout.print("\tx2 - multiply by 2\n", .{});
            try stdout.print("\tadd10 - add 10\n", .{});
            try stdout.print("\tadd1 - add 1\n", .{});
            try stdout.print("\thelp - show this message and exit\n", .{});
            try stdout.flush();
        },
        .list_bits => {
            try stdout.print("You have {} bits!\n", .{bits});
            try stdout.flush();
        }
    }


    return;
}
