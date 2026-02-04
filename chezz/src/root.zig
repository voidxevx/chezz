//! Root module holds all other modules.

// MODULES
pub const board = @import("shared/board.zig");
pub const util = @import("shared/util.zig");
pub const bp = @import("shared/boardposition.zig");
pub const ptm = @import("shared/peicetypemask.zig");