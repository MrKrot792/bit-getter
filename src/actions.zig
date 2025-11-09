const std = @import("std");

pub const Actions = enum {
    list_bits,
    add_1,
    add_10,
    multiply_by_2,
    help,
};

var asociatedActions: std.EnumArray(Actions, std.ArrayList([]const u8)) = .initUndefined();

pub fn init(allocator: std.mem.Allocator) !void {
    var add_1_list: [][]const u8 = try allocator.alloc([]const u8, 3);
    add_1_list[0] = "add_1";
    add_1_list[1] = "add1";
    add_1_list[2] = "a1";
    asociatedActions.set(.add_1, .fromOwnedSlice(add_1_list));

    var add_10_list: [][]const u8 = try allocator.alloc([]const u8, 3);
    add_10_list[0] = "add_10";
    add_10_list[1] = "add10";
    add_10_list[2] = "a10";
    asociatedActions.set(.add_10, .fromOwnedSlice(add_10_list));

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

    var multiply_by_2_list: [][]const u8 = try allocator.alloc([]const u8, 2);
    multiply_by_2_list[0] = "x2";
    multiply_by_2_list[1] = "m2";

    asociatedActions.set(.multiply_by_2, .fromOwnedSlice(multiply_by_2_list));
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
