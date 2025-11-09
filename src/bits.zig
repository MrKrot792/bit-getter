const std = @import("std");

/// Initially, you get 1 bit per second. 
/// However, that speed can be updated.
var bits: f64 = 0;
/// Per second.
var bit_mining_speed: f64 = 1;
/// Per second.
var bit_mining_mining_speed: f64 = 0;

/// `bits_m1` mines bits, `bits_m2` mines `bits_m1`, etc.
const SaveStructure = struct {
    /// The amount of bits player currently has.
    bits: f64,
    bits_m1: f64,
    bits_m2: f64,

    current_time: i128,
};

pub fn tick(delta: f64) void {
    bits += bit_mining_speed * delta;
    bit_mining_speed += bit_mining_mining_speed * delta;
}

pub fn getBits() f64 {
    return bits;
}

pub fn restoreProgress() void {

}

pub fn saveProgress(allocator: std.mem.Allocator) !void {
    const path = try std.fs.getAppDataDir(allocator, "bit-getter");
    defer allocator.free(path);

    std.fs.makeDirAbsolute(path) catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };
    var save_dir = try std.fs.openDirAbsolute(path, .{ .iterate = true });
    defer save_dir.close();

    const save_file_path = try std.fs.path.join(allocator, &[_][]const u8{path, "/save.zon"});
    defer allocator.free(save_file_path);
    var save_file = try save_dir.createFile(save_file_path, .{.truncate = false, .read = true});
    defer save_file.close();

    const current_time = std.time.nanoTimestamp();

    const result: SaveStructure = .{ 
        .bits = bits,
        .bits_m1 = bit_mining_speed,
        .bits_m2 = bit_mining_mining_speed,
        .current_time = current_time,
    };

    var buf: [1024]u8 = undefined;
    var writer = save_file.writer(&buf);

    try std.zon.stringify.serialize(result, .{}, &writer.interface);
    try writer.interface.flush();
}
