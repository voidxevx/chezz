const std = @import("std");
const client = @import("client");

pub fn main() !void {
    try client.board.init();
    defer client.board.deinit();

}
