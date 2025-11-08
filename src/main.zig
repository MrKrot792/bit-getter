const std = @import("std");
const infinity = @import("can_i_be_infinity");
const fps = @import("fps.zig");
const allocator_selector = @import("allocator.zig");

const Actions = enum {
    list_bits,
    add_1,
    add_10,
    multiply_by_2,
    help,
};

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

    _ = args.skip();
    const command = args.next();

    var action: Actions = .help;

    if(command == null) {
        action = .help;
    }
    else if(std.mem.eql(u8, command.?, "help")) {
        action = .help;
    }
    else if(std.mem.eql(u8, command.?, "lb")) {
        action = .list_bits;
    }
    else if(std.mem.eql(u8, command.?, "add1")) {
        action = .add_1;
    }
    else if(std.mem.eql(u8, command.?, "add10")) {
        action = .add_10;
    }
    else if(std.mem.eql(u8, command.?, "x2")) {
        action = .multiply_by_2;
    }

    try run(action);
}

fn run(action: Actions) !void {
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
            try stdout.print("Usage: getbits <COMMAND> <SUBCOMMAND> [VALUE]... \n", .{});
            try stdout.print("COMMANDs: \n", .{});
            try stdout.print("\tlb - list bits\n", .{});
            try stdout.print("\tx2 - multiply by 2\n", .{});
            try stdout.print("\tadd10 - add 10\n", .{});
            try stdout.print("\tadd1 - add 1\n", .{});
            try stdout.print("\thelp - show this message and exit\n", .{});
        },
        .list_bits => {
            try stdout.print("You have {} bits!\n", .{bits});
        }
    }
    try stdout.flush();

    return;
}
