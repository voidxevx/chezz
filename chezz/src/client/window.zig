const std = @import("core").std;

const board = @import("chezz_shared").board;

pub const Window = struct {
    m_WindowWidth: u32,
    m_WindowHeight: u32,
    m_WindowTitle: []const u8,

    pub fn init(height: u32, width: u32, title: []const u8) *Window {
        return &.{
            .m_WindowHeight = height,
            .m_WindowWidth = width,
            .m_WindowTitle = title,
        };
    }
};