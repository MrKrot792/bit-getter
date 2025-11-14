const std = @import("std");

/// Initially, you get 1 bit per second. 
/// However, that speed can be updated.
var bits: f64 = 0;
/// Per second.
var bit_mining_speed: f64 = 1;
/// Per second.
var bit_mining_mining_speed: f64 = 0;
/// Indicates how many time passed since the last run of this command.
var time_passed: i64 = 0;

/// `bits_m1` mines bits, `bits_m2` mines `bits_m1`, etc.
const SaveStructure = struct {
    /// The amount of bits player currently has.
    bits: f64,
    bits_m1: f64,
    bits_m2: f64,

    current_time: i64,
};

/// Tick is in seconds
pub fn tick(delta: f64) void {
    bits += bit_mining_speed * delta;
    bit_mining_speed += bit_mining_mining_speed * delta;
}

pub fn getBits() f64 {
    return bits;
}

pub fn restoreProgress(allocator: std.mem.Allocator) !void {
    var save_file = try getSaveFile(allocator);
    defer save_file.close();

    var buf: [1024]u8 = undefined;
    var reader = save_file.reader(&buf);

    const text = try reader.interface.readAlloc(allocator, try reader.getSize());
    const textZ = try allocator.dupeZ(u8, text);
    allocator.free(text);
    defer allocator.free(textZ);

    const result = std.zon.parse.fromSlice(SaveStructure, allocator, textZ, null, .{}) catch |err| switch (err) {
        error.ParseZon => {
            if((try save_file.stat()).size == 0) {
                std.log.warn("The save file was empty.", .{});
            } else {
                std.log.err("Failed to parse the save file.", .{});
                std.process.exit(1);
                return err;
            }

            return;
        },

        else => try std.zon.parse.fromSlice(SaveStructure, allocator, textZ, null, .{})
    };

    bits = result.bits;
    bit_mining_speed = result.bits_m1;
    bit_mining_mining_speed = result.bits_m2;
    time_passed = std.time.microTimestamp() - result.current_time;
}

pub fn saveProgress(allocator: std.mem.Allocator) !void {
    var save_file = try getSaveFile(allocator);
    defer save_file.close();

    const current_time = std.time.microTimestamp();

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

/// This function also creates directory and the save file if they do not exist
fn getSaveFile(allocator: std.mem.Allocator) !std.fs.File {
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
    const save_file = try save_dir.createFile(save_file_path, .{.truncate = false, .read = true});

    return save_file;
}
