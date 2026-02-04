const std = @import("core").std;
const chezz = @import("chezz_shared");

const socket = @import("clientsocket.zig");

pub fn main() !void {
    try chezz.board.init();
    defer chezz.board.deinit();

    try chezz.board.setBoardPosition(u8, &try chezz.bp.BoardPosition(u8).init(4, 4), 0);
    try chezz.board.setBoardPosition(u8, &try chezz.bp.BoardPosition(u8).init(2, 4), 1);
    
    const mask = chezz.ptm.PeiceMask.init('*', "start");
    
    try chezz.board.addPeiceMask(mask);
    try chezz.board.updateFormattedBoard();
    
    if (chezz.board.FormattedBoard) |r_FBoard| {
        for (r_FBoard.items) |line| {
            std.debug.print("|| ", .{});
            for (line.items) |square|
                std.debug.print("{s}", .{square});
            std.debug.print(" ||\n", .{});
        }
    }
}