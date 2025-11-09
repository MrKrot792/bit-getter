const std = @import("std");
const infinity = @import("can_i_be_infinity");
const fps = @import("fps.zig");
const allocator_selector = @import("allocator.zig");
const actions = @import("actions.zig");
const bit = @import("bits.zig");

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

    try run(action, name.?, allocator);
}

fn run(action: actions.Actions, binary_name: []const u8, allocator: std.mem.Allocator) !void {
    // Setting some writing stuff
    var buff: [1024]u8 = undefined;
    var stdout_file = std.fs.File.stdout();
    var writer = stdout_file.writer(&buff);
    const stdout = &writer.interface;

    std.log.debug("Performing {t}.", .{action});

    bit.restoreProgress();

    switch (action) {
        .help => {
            try stdout.print("Usage: {s} <COMMAND> <SUBCOMMAND> [VALUE]... \n", .{binary_name});
            try stdout.print("COMMANDs: \n", .{});
            try stdout.print("\tlb, ls - show your bit count.\n", .{});
            try stdout.print("\thelp, h - show this message and exit.\n", .{});
            try stdout.print("\tt, tick - calculate bits for one second.\n", .{});
            try stdout.print("\ttc, tick_cont - calculate bits for one second.\n", .{});
            try stdout.flush();
        },
        .list_bits => {
            try stdout.print("You have {} bits!\n", .{bit.getBits()});
            try stdout.flush();
        },
        .tick => {
            try stdout.print("Ticking...\n", .{});
            try stdout.flush();
            std.Thread.sleep(std.time.ns_per_s);
            bit.tick(1.0);
            try stdout.print("You have {} bits!\n", .{bit.getBits()});
            try stdout.flush();
        },
        .tick_cont => {
            try stdout.print("Sorry, this is just a placehorder.", .{});
        }
    }

    try bit.saveProgress(allocator);
    return;
}
