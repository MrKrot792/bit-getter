const std = @import("std");
const builtin = @import("builtin");
const args = @import("args.zig");
const bit = @import("../bits.zig");

const command = struct {
    /// Command. Example: "help".
    command: []const u8,
    /// Short description of the command. Example for "help": "Shows help".
    description: []const u8, 
    /// Long description of the command. Example for "help": "When called, shows this help. Example: $ getbits help".
    long_description: []const u8,

    subcommand: ?[]const u8 = null,

    //                   allocator          stdout          self
    function: *const fn (std.mem.Allocator, *std.Io.Writer, command_ptr: command) anyerror!void,
};

var name: []u8 = undefined;
var commands: std.ArrayList(command) = .empty;

pub fn init(allocator_outer: std.mem.Allocator, name_outer: []const u8) !void {
    try args.parseArguments(allocator_outer);

    try commands.append(allocator_outer, .{ 
        .command = "help",
        .description = "Show this help.",
        .long_description = "You gotta start somewhere...",
        .function = &helpCommand,
    });

    try commands.append(allocator_outer, .{ 
        .command = "ls",
        .description = "List your bits.",
        .long_description = "Lists all your currencies, including B, UB, and EUB.",
        .function = struct {
            fn f(allocator: std.mem.Allocator, stdout: *std.Io.Writer, command_ptr: command) anyerror!void {
                defer _ = command_ptr;
                try bit.restoreProgress(allocator);

                try stdout.print("You have ", .{});
                try bit.getBits().format(stdout);
                try stdout.print("B!\n", .{});
                try stdout.flush();

                try bit.saveProgress(allocator);
            }
        }.f,
    });

    try commands.append(allocator_outer, .{ 
        .command = "tick",
        .description = "Runs the simulation for <time> seconds.",
        .subcommand = "<time>",
        .long_description = "Runs the simulation. <time> is in seconds. <time> default is one second.",
        .function = struct {
            fn f(allocator: std.mem.Allocator, stdout: *std.Io.Writer, command_ptr: command) anyerror!void {
                defer _ = command_ptr;
                try bit.restoreProgress(allocator);

                try stdout.print("Ticking...\n", .{});
                try stdout.flush();

                std.Thread.sleep(std.time.ns_per_s);
                bit.tick(1.0);

                try stdout.print("Done!\n", .{});
                try stdout.flush();

                try stdout.print("You have ", .{});
                try bit.getBits().format(stdout);
                try stdout.print("B!\n", .{});
                try stdout.flush();

                try bit.saveProgress(allocator);
            }
        }.f,
    });

    if (builtin.mode == .Debug) {
        const double_long_description: []const u8 = "Doubles your bits by <by>. <by> should be a float, takes in scientific notation. This actually will crash if the number is more than 1.7e308 (infinity).";
        // This servers as a test for the argument parsing system.
        try commands.append(allocator_outer, .{
            .command = "double",
            .description = "Doubles your bits by <by>.",
            .long_description = double_long_description,
            .subcommand = "<by>",
            .function = struct {
                fn f(allocator: std.mem.Allocator, stdout: *std.Io.Writer, command_ptr: command) anyerror!void {
                    try bit.restoreProgress(allocator);

                    const by_unparsed = args.getArgumentAt(0) catch |err| switch (err) {
                        args.Error.TooFewArguments => {
                            std.log.err("Too few arguments.", .{});
                            try stdout.print("Usage: \n", .{});
                            try printUsage(command_ptr, stdout);
                            try stdout.flush();
                            std.process.exit(1);
                            return err;
                        }
                    };

                    std.log.debug("Parsing {s}...", .{by_unparsed});
                    const by = try std.fmt.parseFloat(f64, by_unparsed);

                    bit.setBits(bit.getBits().mul(.of(by)));

                    try stdout.print("You have ", .{});
                    try bit.getBits().format(stdout);
                    try stdout.print("B!\n", .{});
                    try stdout.flush();

                    try bit.saveProgress(allocator);
                }
            }.f,
        });
    }

    name = try allocator_outer.dupe(u8, name_outer);
}

pub fn deinit(allocator: std.mem.Allocator) void {
    commands.deinit(allocator);
    allocator.free(name);
    args.deinit(allocator);
}

pub fn execute(command_to_execute: ?[]const u8, allocator: std.mem.Allocator) anyerror!void {
    var buf: [1024]u8 = undefined;
    const stdout_file = std.fs.File.stdout();
    var writer = stdout_file.writer(&buf);
    const stdout = &writer.interface;

    if (command_to_execute == null) { 
        try helpCommand(allocator, stdout, commands.items[0]); // Please, zero, the zig god... let `commands.items[0]` always be `help`...
        return; 
    }

    for (commands.items) |value| {
        if(!std.mem.eql(u8, command_to_execute.?, value.command)) { continue; } // If the commands aren't equal, continue.
        else {
            try value.function(allocator, stdout, value);
            return;
        }
    }

    return Error.command_not_found;
}

fn helpCommand(allocator: std.mem.Allocator, stdout: *std.Io.Writer, command_ptr: command) anyerror!void {
    _ = allocator;
    _ = command_ptr;

    try stdout.print("Usage: {s} <command> <sub-command> [args]\n", .{name});
    try stdout.print("Commands: \n", .{});
    for (commands.items) |value| {
        try printUsage(value, stdout);
    }

    try stdout.flush();
}

fn printUsage(command_to_print: command, stdout: *std.Io.Writer) !void {
    if(command_to_print.subcommand == null) {
        try stdout.print("    {s} - {s}\n", .{command_to_print.command, command_to_print.description});
    } else {
        try stdout.print("    {s} {s} - {s}\n", .{command_to_print.command, command_to_print.subcommand.?, command_to_print.description});
    }
}

pub const Error = error {
    command_not_found
};
