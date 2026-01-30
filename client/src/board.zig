//! This module handles all things related to the game board.\
//! Boards are made up of multiple layers of 64 bit integers
//! where each bit is a position on an 8x8 board.\
//! The board is essentially a global class that is entirely encapsuled by this module.

// STANDARD LIBRARIES
const std = @import("std");
const expect = std.testing.expect;

/// The board size is always and 8x8 grid.
const BoardSize = 8;

/// There is a set amount of layers that make up the board
/// for example there is one layer for each peice type.
const BoardLayerCount = 4;

/// Each layer of the board is 64 bit integer that way there
/// is a bit that coresponds to every square on the 8x8 grid.
const BoardLayerType = u64;

/// Board errors - Errors that can be returned by the board if something goes wrong.
pub const BoardError = error {
    BoardAlreadyInitialized,
    BoardNotYetInitialized,
};

/// BoardPositions stores a vector 2d that represents a location on the 8x8 grid. 
/// A board position must be within the size of the board in order for it to be valid.\
/// Positions can be sized differently using different types for the x and y value
/// by default u8 is used but using something like a float can be useful 
/// when you need to store fractional positions.
pub fn BoardPosition(comptime T: anytype) type {
    // compiletime assertion for types being integers or floats
    const info = @typeInfo(T);
    if (info != .int and info != .float) {
        @compileError("[BOARD] Board position can only be sized by integer or float types.");
    }

    return struct {
        // These values don't need to be deallocated because they get allocated on the stack.

        /// X position on the board
        Xpos: T,

        /// Y position on the board
        Ypos: T,

        /// Positions errors - Errors that are created the board positions
        /// for example if the position is out of bounds.
        pub const PositionError = error {
            PositionOutOfBounds,
        };

        /// Creates a position on the board using a specified numeric type for sizing.
        pub fn init(x: T, y: T) !BoardPosition(T) {
            if (x > BoardSize or y > BoardSize)
                return PositionError.PositionOutOfBounds;

            return .{
                .Xpos = x,
                .Ypos = y,
            };
        }

        /// Converts the xy position stored by the BoardPosition and transposes it to the bit location it corelates to.
        pub fn transpose(self: *const BoardPosition(T)) !BoardLayerType {
            if (self.Xpos > BoardSize or self.Ypos > BoardSize)
                return PositionError.PositionOutOfBounds;

            return @as(BoardLayerType, (self.Ypos * BoardSize) + self.Xpos);
        }

        /// Translates a position by the value of another position.
        pub fn translate(self: *BoardPosition(T), other: *const BoardPosition(T)) !void {
            self.Xpos += other.Xpos;
            self.Ypos += other.Ypos;

            if (self.Xpos > BoardSize or self.Ypos > BoardSize)
                return PositionError.PositionOutOfBounds;
        }

    };
} 

test "Board position with u8 sizing" {
    // create a u8 board location
    const pos = try BoardPosition(u8).init(1, 1);
    // assert it was accuratly created
    try expect(pos.Xpos == 1 and pos.Ypos == 1);

    // assert transposing the position works
    const trans = try pos.transpose();
    try expect(trans == 9);

    // mutable position
    var pos2 = try BoardPosition(u8).init(5, 3);
    // translating a position
    try pos2.translate(&pos);
    // assert the translation works.
    try expect(pos2.Xpos == 6 and pos2.Ypos == 4);
}







/// Allocator designated for allocating the layers of the board.
const BoardAllocator = std.heap.page_allocator;

/// The layers of the board.\
/// This is the maim variable that dictates what the board looks like.
var Board: ?[]BoardLayerType = undefined;

/// Initializes and allocates the board's layers.\
/// This will throw an error if the board was already initialized.
pub fn init() !void {
    if (Board) |_| {
        return BoardError.BoardAlreadyInitialized;
    }
}

/// Frees the layers of the board and resets the board to be reinitialized again later.\
/// This function will not throw an error if the board has not been initialized
/// simply because using defer with this function is crucial for memory handling.
pub fn deinit() void {
    BoardAllocator.free(Board.?);
    Board = undefined;
}

test "Initialize and terminate board" {
    try init();
    defer deinit();
}
