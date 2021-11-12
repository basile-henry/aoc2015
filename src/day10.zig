const std = @import("std");
const print = std.debug.print;

pub fn main() anyerror!void {
    const allocator = std.heap.page_allocator;

    const input = "1321131112";

    var current = std.ArrayList(u8).init(allocator);
    defer current.deinit();

    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();

    try current.ensureTotalCapacity(7_000_000);
    try buffer.ensureTotalCapacity(7_000_000);

    try current.appendSlice(input);

    var step: usize = 0;
    while (step < 50) : (step += 1) {
        var run: usize = 1;

        for (current.items) |c, i| {
            if (i > 0) {
                const l = current.items[i - 1];

                if (c == l) {
                    run += 1;
                } else {
                    try std.fmt.format(buffer.writer(), "{d}{c}", .{ run, l });

                    run = 1;
                }
            }
        }

        try std.fmt.format(buffer.writer(), "{d}{c}", .{ run, current.items[current.items.len - 1] });

        std.mem.swap(std.ArrayList(u8), &current, &buffer);
        buffer.clearRetainingCapacity();

        if (step == 40) {
            print("Part 1: {d}\n", .{current.items.len});
        }
    }

    print("Part 2: {d}\n", .{current.items.len});
}
