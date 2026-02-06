const std = @import("core").std;

const board = @import("chezz_shared").board;

pub const Window = struct {
    WindowWidth: u32,
    WindowHeight: u32,
    WindowTitle: []const u8,
    WindowTitleOffsetX: u32,
    WindowTitleOffsetY: u32,
};

pub const WindowBuilder = struct {
    WindowWidth: ?u32,
    WindowHeight: ?u32,
    WindowTitle: ?[]const u8,
    WindowTitleOffsetX: ?u32,
    WindowTitleOffsetY: ?u32,

    const WindowBuildError = error {
        VolitilePropertyNotInitialized,
        PropertyAlreadyInitialized,
        PropertyOutOfBounds,
    };

    pub fn init() WindowBuilder {
        return .{
            .WindowHeight = null,
            .WindowWidth = null,
            .WindowTitle = null,
            .WindowTitleOffsetX = null,
            .WindowTitleOffsetY = null,
        };
    }

    pub fn setWidthHeight(self: *WindowBuilder, width: u32, height: u32) !*WindowBuilder {
        if (self.WindowHeight != null or self.WindowWidth != null)
            return WindowBuildError.PropertyAlreadyInitialized;

        self.WindowHeight = height;
        self.WindowWidth = width;

        return self;
    }

    pub fn setHeight(self: *WindowBuilder, height: u32) !*WindowBuilder {
        if (self.WindowHeight != null) 
            return WindowBuildError.PropertyAlreadyInitialized;

        self.WindowHeight = height;
    }

    pub fn setWidth(self: *WindowBuilder, width: u32) !*WindowBuilder {
        if (self.WindowWidth != null)
            return WindowBuildError.PropertyAlreadyInitialized;

        self.WindowWidth = width;
    }

    pub fn setTitle(self: *WindowBuilder, title: []const u8) !*WindowBuilder {
        if (self.WindowTitle != null)
            return WindowBuildError.PropertyAlreadyInitialized;

        self.WindowTitle = title;
    }

    pub fn setTitleOffset(self: *WindowBuilder, titleOffsetX: u32, titleOffsetY: u32) *WindowBuilder {
        if (self.WindowTitleOffsetX != null or self.WindowTitleOffsetY != null)
            return WindowBuildError.PropertyAlreadyInitialized;

        self.WindowTitleOffsetX = titleOffsetX;
        self.WindowTitleOffsetY = titleOffsetY;
    }

    pub fn setTitleOffsetX(self: *WindowBuilder, offsetX: u32) !*WindowBuilder {
        if (self.WindowTitleOffsetX != null)
            return WindowBuildError.PropertyAlreadyInitialized;

        self.WindowTitleOffsetX = offsetX;
    }

    pub fn setTitleOffsetY(self: *WindowBuilder, offsetY: u32) !*WindowBuilder {
        if (self.WindowTitleOffsetY != null)
            return WindowBuildError.PropertyAlreadyInitialized;

        self.WindowTitleOffsetY = offsetY;
    }

    pub fn noTitleOffset(self: *WindowBuilder) !*WindowBuilder {
         if (self.WindowTitleOffsetX != null or self.WindowTitleOffsetY != null)
            return WindowBuildError.PropertyAlreadyInitialized;

        self.WindowTitleOffsetX = 0;
        self.WindowTitleOffsetY = 0;
    }

    pub fn win(self: *const WindowBuilder) !*Window {
        if (
            self.WindowHeight == null or
            self.WindowWidth == null or
            self.WindowTitle == null or
            self.WindowTitleOffsetX == null or
            self.WindowTitleOffsetY == null
        ) return WindowBuildError.VolitilePropertyNotInitialized;

        return &.{
            .WindowHeight = self.WindowHeight.?,
            .WindowWidth = self.WindowWidth.?,
            .WindowTitle = self.WindowTitle.?,
            .WindowTitleOffsetX = self.WindowTitleOffsetX.?,
            .WindowTitleOffsetY = self.WindowTitleOffsetY.?
        };
    }
};

test "build window" {
    try WindowBuilder.init().setWidthHeight(0, 0).setTitle("Test window").noTitleOffset().win();
}