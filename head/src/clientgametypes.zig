const std = @import("std");


pub const ClientGame = union(enum) {
    ClientWaitingRoom: struct {
        
    },

    PairWaitingRoom: struct {

    },
    PairGame: struct {

    },
};