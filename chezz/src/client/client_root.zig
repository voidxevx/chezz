const std = @import("core").std;
const chezz = @import("chezz_shared");

const socket = @import("clientsocket.zig");

/// general allocator for startup allocations.
const generalAllocator = std.heap.page_allocator;


/// arguements arised during the parsing proccess of the cli arguements.
const ArguementErrors = error {
    FailedToAllocateArguements,
};

/// main function -- handles the initialization of all segments of the game.\
/// Holds the main game loop that propegates the tick updates.
pub fn main() !void {

    // initialize the board
    try chezz.board.init();
    defer chezz.board.deinit();

    // allocate cli arguements
    const args = std.process.argsAlloc(generalAllocator) catch {
        std.debug.print("Failed to allocate arguements.", .{});
        return ArguementErrors.FailedToAllocateArguements;
    };


    // optional command line arguements
    var isLocal = false;

    // interprite cli args
    for (args) |arg| {
        if (std.mem.eql(u8, arg, "local")) {
            isLocal = true;
        }
    }

    // initialize the clients socket
    try socket.initSocket(isLocal);
    defer socket.deinitSocket();


    // DEBUG //
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


// Test initialization of the client socket.
test "initialize socket" {
    try socket.initSocket(true);
    defer socket.deinitSocket();
}