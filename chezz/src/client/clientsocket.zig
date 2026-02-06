const std = @import("core").std;
const posix = std.posix;

const util = @import("chezz_shared").util;

/// The socket that the client is attached to.
var clientSocket: ?posix.socket_t = null;
/// the address of the client.
var clientAddress: ?std.net.Address = null;

/// allocattor for the client socket.\
/// Use to allocate buffers
const ClientAllocator = std.heap.page_allocator;

/// Error arised durng client connection
const ClientConnectionError = error {
    SocketAlreadyInitialized,
    SocketNotYetInitialized,
};

/// initialize the socket for the client
pub fn initSocket(local: bool) !void {
    if (clientSocket != null)
        return ClientConnectionError.SocketAlreadyInitialized;

    if (local) {
        clientAddress = std.net.Address.initIp4(.{ 127, 0, 0, 1 }, util.port);
    } else
        clientAddress = std.net.Address.initIp4(.{0, 0, 0, 0}, util.port);

    clientSocket = try posix.socket(
        posix.AF.INET, 
        posix.SOCK.DGRAM, 
        posix.IPPROTO.UDP
    );

    try posix.bind(clientSocket.?, @ptrCast(&clientAddress.?.any), clientAddress.?.in.getOsSockLen());
    std.debug.print("Client listening on {f}\n", .{clientAddress.?});
}

/// deinitialize the client by closing the socket
pub fn deinitSocket() void {
    posix.close(clientSocket.?);
}