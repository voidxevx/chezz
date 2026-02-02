const std = @import("pch.zig").std;

pub const PeiceMask = struct {
    charMask: u8,
    peiceName: []const u8,

    pub fn init(char: u8, name: []const u8) PeiceMask {
        return .{
            .charMask = char,
            .peiceName = name,
        };
    }
};