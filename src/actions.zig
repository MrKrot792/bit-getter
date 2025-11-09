//! This file requiers rewrite.
//! ...but I can do it later, right?
const std = @import("std");

pub const Actions = enum {
    list_bits,
    help,
    tick,
    tick_cont,
};

var asociatedActions: std.EnumArray(Actions, std.ArrayList([]const u8)) = .initUndefined();

pub fn init(allocator: std.mem.Allocator) !void {
    var help_list: [][]const u8 = try allocator.alloc([]const u8, 4);
    help_list[0] = "help";
    help_list[1] = "--help";
    help_list[2] = "-h";
    help_list[3] = "h";
    asociatedActions.set(.help, .fromOwnedSlice(help_list));

    var list_bits_list: [][]const u8 = try allocator.alloc([]const u8, 4);
    list_bits_list[0] = "ls";
    list_bits_list[1] = "lb";
    list_bits_list[2] = "l";
    list_bits_list[3] = "list";
    asociatedActions.set(.list_bits, .fromOwnedSlice(list_bits_list));

    var tick_list: [][]const u8 = try allocator.alloc([]const u8, 2);
    tick_list[0] = "tick";
    tick_list[1] = "t";
    asociatedActions.set(.tick, .fromOwnedSlice(tick_list));

    var tick_cont_list: [][]const u8 = try allocator.alloc([]const u8, 2);
    tick_cont_list[0] = "tick_cont";
    tick_cont_list[1] = "tc";
    asociatedActions.set(.tick_cont, .fromOwnedSlice(tick_cont_list));
}

/// Deiniting every list...
pub fn deinit(allocator: std.mem.Allocator) void {
    var iterator = asociatedActions.iterator();

    while (true) {
        const next = iterator.next();
        if(next == null) break;

        next.?.value.deinit(allocator);
    }
}

pub fn actionByString(str: []const u8, allocator: std.mem.Allocator) !Actions {
    var i = asociatedActions.iterator();

    while (true) {
        const next = i.next();
        if(next == null) break;

        for(next.?.value.items) |value| {
            const buf: []u8 = try allocator.alloc(u8, value.len);
            defer allocator.free(buf);
            if(std.mem.eql(u8, std.ascii.lowerString(buf, value), str)) {
                return next.?.key;
            }
        }
    }

    return .help;
}

pub fn actionByStringOrNull(str: ?[]const u8, allocator: std.mem.Allocator) !Actions {
    if(str == null) return .help 
    else return try actionByString(str.?, allocator);
}
