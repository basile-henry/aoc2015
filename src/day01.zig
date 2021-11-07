const std = @import("std");
const print = std.debug.print;

pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile(
        "./inputs/day01.txt",
        .{ .read = true },
    );

    var buffer: [1024]u8 = undefined;
    var bytes = try file.read(&buffer);

    var floor: isize = 0;
    var position: usize = 0;
    var basement_position: ?usize = null;

    while (bytes > 0) {
        for (buffer[0..bytes]) |b| {
            position += 1;

            if (b == '(') {
                floor += 1;
            } else if (b == ')') {
                floor -= 1;
            }

            if (basement_position == null and floor == -1) {
                basement_position = position;
            }
        }

        bytes = try file.read(&buffer);
    }

    print("End floor: {d}\n", .{floor});
    print("Basement position: {d}\n", .{basement_position});
}
