const std = @import("std");
const print = std.debug.print;

pub fn main() anyerror!void {
    const input = "iwrupvqb";

    var running = true;
    const t0 = try std.Thread.spawn(.{}, find_md5, .{ true, input, &running, 0, 4 });
    const t1 = try std.Thread.spawn(.{}, find_md5, .{ true, input, &running, 1, 4 });
    const t2 = try std.Thread.spawn(.{}, find_md5, .{ true, input, &running, 2, 4 });
    const t3 = try std.Thread.spawn(.{}, find_md5, .{ true, input, &running, 3, 4 });
    t0.join();
    t1.join();
    t2.join();
    t3.join();

    running = true;
    const t4 = try std.Thread.spawn(.{}, find_md5, .{ false, input, &running, 0, 4 });
    const t5 = try std.Thread.spawn(.{}, find_md5, .{ false, input, &running, 1, 4 });
    const t6 = try std.Thread.spawn(.{}, find_md5, .{ false, input, &running, 2, 4 });
    const t7 = try std.Thread.spawn(.{}, find_md5, .{ false, input, &running, 3, 4 });
    t4.join();
    t5.join();
    t6.join();
    t7.join();
}

fn find_md5(find_5: bool, input: []const u8, running: *bool, start: usize, step: usize) void {
    var i: usize = start;

    const Md5 = std.crypto.hash.Md5;
    var hash_buf: [16]u8 = undefined;

    var allocator_buffer: [100]u8 = undefined;
    var allocator = &std.heap.FixedBufferAllocator.init(&allocator_buffer).allocator;

    while (running.*) {
        var s = std.fmt.allocPrint(allocator, "{d}", .{i}) catch @panic("Unhandled");
        defer allocator.free(s);

        var h = Md5.init(.{});
        h.update(input);
        h.update(s);
        h.final(&hash_buf);

        var hash_hex = std.fmt.allocPrint(allocator, "{s}", .{std.fmt.fmtSliceHexUpper(&hash_buf)}) catch @panic("Unhandled");
        defer allocator.free(hash_hex);

        if (find_5) {
            if (std.mem.eql(u8, hash_hex[0..5], "00000")) {
                print("Number {d} produces hash {s}\n", .{ i, std.fmt.fmtSliceHexUpper(&hash_buf) });
                running.* = false;
                return;
            }
        } else {
            if (std.mem.eql(u8, hash_hex[0..6], "000000")) {
                print("Number {d} produces hash {s}\n", .{ i, std.fmt.fmtSliceHexUpper(&hash_buf) });
                running.* = false;
                return;
            }
        }

        i += step;
    }
}
