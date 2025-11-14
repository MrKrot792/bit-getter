//! This file requiers rewrite.
//! ...but I can do it later, right?
const std = @import("std");
const bit = @import("bits.zig");

const command = struct {
    command: []const u8,
    description: []const u8,
    subcommand: ?[]const u8 = null,

    function: *const fn (std.mem.Allocator, *std.Io.Writer) anyerror!void,
};

var name: []u8 = undefined;
var commands: std.ArrayList(command) = .empty;

pub fn init(allocator_outer: std.mem.Allocator, name_outer: []const u8) !void {
    try commands.append(allocator_outer, .{ 
        .command = "help",
        .description = "Show this help.",
        .function = &helpCommand,
    });

    try commands.append(allocator_outer, .{ 
        .command = "ls",
        .description = "List your bits.",
        .function = struct {
            fn f(allocator: std.mem.Allocator, stdout: *std.Io.Writer) anyerror!void {
                try bit.restoreProgress(allocator);

                try stdout.print("You have {}B!\n", .{bit.getBits()});
                try stdout.flush();

                try bit.saveProgress(allocator);
            }
        }.f,
    });

    try commands.append(allocator_outer, .{ 
        .command = "tick",
        .description = "Runs the simulation for 1 second.",
        .function = struct {
            fn f(allocator: std.mem.Allocator, stdout: *std.Io.Writer) anyerror!void {
                try bit.restoreProgress(allocator);

                try stdout.print("Ticking...\n", .{});
                try stdout.flush();

                std.Thread.sleep(std.time.ns_per_s);
                bit.tick(1.0);

                try stdout.print("Done!\n", .{});
                try stdout.flush();

                try stdout.print("Now you have {e}B!\n", .{bit.getBits()});
                try stdout.flush();

                try bit.saveProgress(allocator);
            }
        }.f,
    });

    name = try allocator_outer.dupe(u8, name_outer);
}

pub fn deinit(allocator: std.mem.Allocator) void {
    commands.deinit(allocator);
    allocator.free(name);
}

pub fn execute(command_to_execute: ?[]const u8, allocator: std.mem.Allocator) anyerror!void {
    var buf: [1024]u8 = undefined;
    const stdout_file = std.fs.File.stdout();
    var writer = stdout_file.writer(&buf);
    const stdout = &writer.interface;

    if (command_to_execute == null) { 
        try helpCommand(allocator, stdout); 
        return; 
    }

    for (commands.items) |value| {
        if(!std.mem.eql(u8, command_to_execute.?, value.command)) { continue; }
        else {
            try value.function(allocator, stdout);
            return;
        }
    }

    return Error.command_not_found;
}

fn helpCommand(allocator: std.mem.Allocator, stdout: *std.Io.Writer) anyerror!void {
    _ = allocator;

    try stdout.print("Usage: {s} <command> <sub-command> [args]\n", .{name});
    try stdout.print("Commands: \n", .{});
    for (commands.items) |value| {
        if(value.subcommand == null) {
            try stdout.print("    {s} - {s}\n", .{value.command, value.description});
        } else {
            try stdout.print("    {s}, {s} - {s}\n", .{value.command, value.subcommand.?, value.description});
        }
    }

    try stdout.flush();
}

pub const Error = error {
    command_not_found
};
