const std = @import("core").std;

var clientsocket: ?std.os.socket_t = null;

const ClientConnectionError = error {
    SocketAlreadyInitialized,
    SocketNotYetInitialized,
};

const ClientSocket = struct {
    address: std.net.Address,
    socket: std.os.socket_t,

    pub fn init() !ClientSocket {

    }

};