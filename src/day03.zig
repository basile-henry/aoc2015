const std = @import("std");
const print = std.debug.print;

pub fn main() anyerror!void {
    const allocator = std.heap.page_allocator;

    var file = try std.fs.cwd().openFile(
        "./inputs/day03.txt",
        .{
            .read = true,
        },
    );

    try part1(allocator, file);

    try file.seekTo(0);
    try part2(allocator, file);
}

fn part1(allocator: *std.mem.Allocator, file: std.fs.File) anyerror!void {
    var buffer: [1024]u8 = undefined;
    var bytes = try file.read(&buffer);

    const Pos = struct { x: i32, y: i32 };
    var houses = std.AutoHashMap(Pos, usize).init(allocator);
    defer houses.deinit();

    var santa = Pos{ .x = 0, .y = 0 };

    while (bytes > 0) {
        for (buffer[0..bytes]) |c| {
            switch (c) {
                '>' => santa.x += 1,
                '<' => santa.x -= 1,
                '^' => santa.y += 1,
                'v' => santa.y -= 1,
                '\n' => break,
                else => @panic("Unexpected"),
            }

            var entry = try houses.getOrPutValue(santa, 0);

            entry.value_ptr.* += 1;
        }

        bytes = try file.read(&buffer);
    }

    print("Number of houses: {d}\n", .{houses.count()});
}

fn part2(allocator: *std.mem.Allocator, file: std.fs.File) anyerror!void {
    var buffer: [1024]u8 = undefined;
    var bytes = try file.read(&buffer);

    const Pos = struct { x: i32, y: i32 };
    var houses = std.AutoHashMap(Pos, usize).init(allocator);
    defer houses.deinit();

    var santas = [2]Pos{
        .{ .x = 0, .y = 0 },
        .{ .x = 0, .y = 0 },
    };

    var current_santa: usize = 0;

    while (bytes > 0) {
        for (buffer[0..bytes]) |c| {
            switch (c) {
                '>' => santas[current_santa].x += 1,
                '<' => santas[current_santa].x -= 1,
                '^' => santas[current_santa].y += 1,
                'v' => santas[current_santa].y -= 1,
                '\n' => break,
                else => @panic("Unexpected"),
            }

            var entry = try houses.getOrPutValue(santas[current_santa], 0);

            entry.value_ptr.* += 1;

            current_santa ^= 1;
        }

        bytes = try file.read(&buffer);
    }

    print("Number of houses with robot santa: {d}\n", .{houses.count()});
}
