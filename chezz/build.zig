const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Core module (essentially the pch)
    // included by all modules, executables, andlibraries.
    const core_mod = b.addModule("core", .{
        .root_source_file = b.path("src/core.zig"),
        .target = target,
        .optimize = optimize,
    });


    // shared module.
    // includes objects and functions used by both the client and the server.
    const shared_mod = b.addModule("chezz_shared", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "core", .module = core_mod }
        }
    });

    // I am creating a static library for the shared module.
    // Im not going to use it but it's nice to have.
    const shared_lib = b.addLibrary(.{
        .name = "chezz_shared",
        .linkage = .static,
        .root_module = shared_mod,
    });
    b.installArtifact(shared_lib);


    // Module for the client executale
    const client_mod = b.createModule(.{
        .root_source_file = b.path("src/client/client_root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "chezz_shared", .module = shared_mod },
            .{ .name = "core", .module = core_mod }
        },
    });

    // client executable - used by individual players as an interface to the head.
    const client_exe = b.addExecutable(.{
        .name = "chezz",
        .root_module = client_mod,
    });


    // Module for the server head executable
    const head_mod = b.createModule(.{
        .root_source_file = b.path("src/head/head_root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "chezz_shared", .module = shared_mod },
            .{ .name = "core", .module = core_mod }
        }
    });

    // server head executable - manages players and communications between players and the game
    const head_exe = b.addExecutable(.{
        .name = "chezz_head",
        .root_module = head_mod,
    });

    // artifacts for the executables
    b.installArtifact(client_exe);
    b.installArtifact(head_exe);




    // Run client excutable step
    const run_client_step = b.step("rc", "Run the client app");

    const run_client_cmd = b.addRunArtifact(client_exe);
    run_client_step.dependOn(&run_client_cmd.step);

    run_client_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_client_cmd.addArgs(args);
    }



    // Run server head executable step
    const run_head_step = b.step("rh", "Run the server head app");

    const run_head_cmd = b.addRunArtifact(head_exe);
    run_head_step.dependOn(&run_head_cmd.step);

    run_head_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_head_cmd.addArgs(args);
    }

    ///////////
    // TESTS //
    ///////////

    // shared module tests
    const shared_mod_tests = b.addTest(.{
        .root_module = shared_mod,
    });

    // client module tests
    const client_mod_tests = b.addTest(.{
        .root_module = client_mod,
    });


    // server head tests
    const head_mod_tests = b.addTest(.{
        .root_module = head_mod
    });

    // run test artifacts
    const run_shared_tests = b.addRunArtifact(shared_mod_tests);
    const run_client_tests = b.addRunArtifact(client_mod_tests);
    const run_head_tests = b.addRunArtifact(head_mod_tests);

    // test only the tests from the client and shared module
    const client_test_step = b.step("tc", "Run tests for client");
    client_test_step.dependOn(&run_client_tests.step);
    client_test_step.dependOn(&run_shared_tests.step);

    // run only the tests from the server head and shared module
    const head_test_step = b.step("th", "Run tests for head");
    head_test_step.dependOn(&run_head_tests.step);
    head_test_step.dependOn(&run_shared_tests.step);

    // run tests for all modules
    const shared_test_step = b.step("t", "Run tests for both head and client");
    shared_test_step.dependOn(&run_shared_tests.step);
    shared_test_step.dependOn(&run_head_tests.step);
    shared_test_step.dependOn(&run_client_tests.step);


    // run tests only from the shared module/
    const shared_only_tests_step = b.step("ts", "Run tests for only the shared module");
    shared_only_tests_step.dependOn(&run_shared_tests.step);

}
