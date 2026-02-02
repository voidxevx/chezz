//! This module handles all things related to the game board.\
//! Boards are made up of multiple layers of 64 bit integers
//! where each bit is a position on an 8x8 board.\
//! The board is essentially a global class that is entirely encapsuled by this module.

// pch
const std = @import("pch.zig").std;
const expect = @import("pch.zig").expect;

const util = @import("util.zig");
const bp = @import("boardposition.zig");
const ptm = @import("peicetypemask.zig");

/// Board errors - Errors that can be returned by the board if something goes wrong.
pub const BoardError = error {
    BoardAlreadyInitialized,
    BoardNotYetInitialized,
};

// tracking for board initialization status.
pub var board_initialized = false;


test "Board position with u8 sizing" {
    // create a u8 board location
    const pos = try bp.BoardPosition(u8).init(1, 1);
    // assert it was accuratly created
    try expect(pos.Xpos == 1 and pos.Ypos == 1);

    // assert transposing the position works
    const trans = try pos.transpose();
    try expect(trans == 9);

    // mutable position
    var pos2 = try bp.BoardPosition(u8).init(5, 3);
    // translating a position
    try pos2.translate(&pos);
    // assert the translation works.
    try expect(pos2.Xpos == 6 and pos2.Ypos == 4);
}







/// Allocator designated for allocating the layers of the board.
const BoardAllocator = std.heap.page_allocator;

/// The layers of the board.\
/// This is the main variable that dictates what the board looks like.
var Board: ?[]util.BoardLayerType = null;

/// Formatted board used for printing.
/// Uses the board layers as a reference of where each peices 
/// are and how they should be rendered.
pub var FormattedBoard: ?std.ArrayList(std.ArrayList([]const u8)) = null;

/// Initializes and allocates the board's layers.\
/// This will throw an error if the board was already initialized.
pub fn init() !void {
    if (Board) |_|
        return BoardError.BoardAlreadyInitialized;

    Board = try BoardAllocator.alloc(util.BoardLayerType, util.BoardLayerCount);
    for (0..util.BoardLayerCount) |i|
        Board.?[i] = 0;

    if (FormattedBoard) |_|
        return BoardError.BoardAlreadyInitialized;

    FormattedBoard = try std.ArrayList(std.ArrayList([]const u8)).initCapacity(BoardAllocator, util.BoardSize);
    for (0..util.BoardSize) |_| {
        var line = try std.ArrayList([]const u8).initCapacity(BoardAllocator, util.BoardSize);
        for (0..util.BoardSize) |_|
            try line.append(BoardAllocator, "");
        try FormattedBoard.?.append(BoardAllocator, line);
    }

    board_initialized = true;
}

/// Frees the layers of the board and resets the board to be reinitialized again later.\
/// This function will not throw an error if the board has not been initialized
/// simply because using defer with this function is crucial for memory handling.
pub fn deinit() void {
    BoardAllocator.free(Board.?);
    Board = null;

    // free each row of the formatted board
    while (FormattedBoard.?.items.len > 0) {
        var popped = FormattedBoard.?.pop();
        popped.?.deinit(BoardAllocator);
    }

    // free the entire formatted board.
    FormattedBoard.?.deinit(BoardAllocator);
    FormattedBoard = null;

    board_initialized = false;
}

test "Initialize and terminate board" {
    try init();
    defer deinit();
}

/// Maps the state of a grid point into it type by a 3 bit bitset.
const GridHighlightState = enum(u3) {
    Normal_Primary     = 0b000,
    Normal_Secondary   = 0b001,
    Selected_Primary   = 0b010,
    Selected_Secondary = 0b011,
    Movable_Primary    = 0b100,
    Movable_Secondary  = 0b101,
    SelMov_Primary     = 0b110,
    SelMov_Secondary   = 0b111,
};

/// matches the grid state to its coloration 
fn MatchGridHighlightState(state: GridHighlightState) []const u8 {
    switch (state) {
        // white
        GridHighlightState.Normal_Primary     => return "\x1b[47m\x1b[30m ",
        // black
        GridHighlightState.Normal_Secondary   => return "\x1b[40m\x1b[37m ",

        // cyan
        GridHighlightState.Selected_Primary   => return "\x1b[46m\x1b[35m ",
        // magenta
        GridHighlightState.Selected_Secondary => return "\x1b[45m\x1b[36m ",

        // yellow
        GridHighlightState.Movable_Primary,
        GridHighlightState.Movable_Secondary  => return "\x1b[43m\x1b[30m ",

        // blue
        GridHighlightState.SelMov_Primary     => return "\x1b[44m\x1b[31m ",
        // red
        GridHighlightState.SelMov_Secondary   => return "\x1b[41m\x1b[34m ",
    }
}

/// Updates the formatted board to match the binary board veiw.\
/// This must be called before the board gets printed.
pub fn updateFormattedBoard() !void {
    if (FormattedBoard == null) {
        return BoardError.BoardNotYetInitialized;
    }

    var r_FBoard = &FormattedBoard.?;
    for (0..util.BoardSize) |y| {
        var line = &r_FBoard.items[y];
        for (0..util.BoardSize) |x| {
            const square = &line.items[x];
            BoardAllocator.free(square.*);
            const pos = try bp.BoardPosition(usize).init(x, y);
            const transpose = try pos.transpose();

            // determine the squares state

            var state: u3 = 0b0;
            // if the sqaure is white or black
            if ((x + y) % 2 == 0)
                state |= 0b1;
            // if the square is selected
            if ((Board.?[0] & transpose) > 0)
                state |= 0b10;
            // if the square is movable
            if ((Board.?[1] & transpose) > 0)
                state |= 0b100;

            // get the formatted string
            const color = MatchGridHighlightState(@enumFromInt(state));
            square.* = try std.mem.concat(BoardAllocator, u8, &.{color, " ", " \x1b[0m"});
        }
    }
}

test "Update formatted board and print it" {
    try init();
    defer deinit();

    try updateFormattedBoard();

    // print out board
    if (FormattedBoard) |r_FBoard| {
        for (r_FBoard.items) |line| {
            for (line.items) |square|
                std.debug.print("{s}", .{square});
            std.debug.print("\n", .{});
        }
    }
}


/// Sets a position in a layer on the board to be true. 
/// This is used to set where a peice of a specific type is located
/// on the board.
pub fn setBoardPosition(comptime sizing: anytype, position: *const bp.BoardPosition(sizing), layer: usize) !void {
    if (Board) |r_Board| {
        const transpose = try position.transpose();
        r_Board[layer] |= transpose;
    } else
        return BoardError.BoardNotYetInitialized;
}

/// list of all peice masks each mask holds the character that will be printed.
/// The index in the array coresponds with the index on the board array that marks 
/// if there is a peice of that type at that location.
var masks: std.ArrayList(ptm.PeiceMask) = .empty;

/// Adds a mask to the list of masks.
pub fn addPeiceMask(mask: ptm.PeiceMask) !void {
    try masks.append(BoardAllocator, mask);
}