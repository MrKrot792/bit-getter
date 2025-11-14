const std = @import("std");

pub var subcommands: std.ArrayList([]const u8) = .empty;

pub fn parseArguments(allocator: std.mem.Allocator) !void {
    var args = try std.process.argsWithAllocator(allocator);
    // Skipping the name and the command, as they already should be processed...
    const r1 = args.skip();
    const r2 = args.skip();

    if(!(r1 and r2)) return; // Silently returning from the function....
                             // Surelly this won't cause any bugs later, right?
                             //
                             // right..??

    defer args.deinit();
    while (true) {
        const next = args.next();
        if(next == null) break;
        try subcommands.append(allocator, next.?);
    }
}

pub fn deinit(allocator: std.mem.Allocator) void {
    subcommands.deinit(allocator);
}

/// Unparsed, the caller must parse the string
/// 0 - the subcommand 
/// 1 - the first argument of the subcommand
/// 2, 3, 4 - other arguments
///
/// Example:
/// ```
/// $ getbits command subcommand arg1 arg2 arg3
/// 
/// getArgumentAt(0) -> subcommand
/// getArgumentAt(1) -> arg1
/// getArgumentAt(2) -> arg2
/// getArgumentAt(3) -> arg3
/// ```
pub fn getArgumentAt(at: u32) ![]const u8 {
    if (subcommands.items.len <= at) return Error.TooFewArguments;
    return subcommands.items[at];
}

/// Placehorder. Use `getArgumentAt()` instead.
pub fn parseArgumentAt(at: u32, T: type) !T {
    _ = at;
}

pub const Error = error {
    TooFewArguments,
};
