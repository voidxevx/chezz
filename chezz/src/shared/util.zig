/// The board size is always and 8x8 grid.
pub const BoardSize = 8;

/// There is a set amount of layers that make up the board
/// for example there is one layer for each peice type.\
/// \
/// Layers:\
/// 0 - Selection Highlight\
/// 1 - Move Highlights
pub const BoardLayerCount = 2;

/// Each layer of the board is 64 bit integer that way there
/// is a bit that coresponds to every square on the 8x8 grid.
pub const BoardLayerType = u64;