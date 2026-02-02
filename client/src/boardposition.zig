const util = @import("util.zig");

/// BoardPositions stores a vector 2d that represents a location on the 8x8 grid. 
/// A board position must be within the size of the board in order for it to be valid.\
/// Positions can be sized differently using different types for the x and y value
/// by default u8 is used but using something like a float can be useful 
/// when you need to store fractional positions.
pub fn BoardPosition(comptime T: anytype) type {
    // compiletime assertion for types being integers or floats
    const info = @typeInfo(T);
    if (info != .int and info != .float)
        @compileError("Board position can only be sized by integer or float types.");

    return struct {
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
            if (x > util.BoardSize or y > util.BoardSize)
                return PositionError.PositionOutOfBounds;

            return .{
                .Xpos = x,
                .Ypos = y,
            };
        }

        /// Converts the xy position stored by the BoardPosition and transposes it to the bit location it corelates to.
        pub fn transpose(self: *const BoardPosition(T)) !util.BoardLayerType {
            if (self.Xpos > util.BoardSize or self.Ypos > util.BoardSize)
                return PositionError.PositionOutOfBounds;

            const linearPos = (self.Ypos * util.BoardSize) + self.Xpos;
            return @as(util.BoardLayerType, 0b1) << @intCast(linearPos);
        }

        /// Translates a position by the value of another position.
        pub fn translate(self: *BoardPosition(T), other: *const BoardPosition(T)) !void {
            self.Xpos += other.Xpos;
            self.Ypos += other.Ypos;

            if (self.Xpos > util.BoardSize or self.Ypos > util.BoardSize)
                return PositionError.PositionOutOfBounds;
        }

    };
} 
