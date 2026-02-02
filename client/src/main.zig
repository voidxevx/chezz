const std = @import("std");
const client = @import("client");

pub fn main() !void {
    try client.board.init();
    defer client.board.deinit();

    try client.board.setBoardPosition(u8, &try client.bp.BoardPosition(u8).init(4, 4), 0);
    try client.board.setBoardPosition(u8, &try client.bp.BoardPosition(u8).init(2, 4), 1);

    try client.board.updateFormattedBoard();

    if (client.board.FormattedBoard) |r_FBoard| {
        for (r_FBoard.items) |line| {
            std.debug.print("║ ", .{});
            for (line.items) |square|
                std.debug.print("{s}", .{square});
            std.debug.print(" ║\n", .{});
        }
    }
}
