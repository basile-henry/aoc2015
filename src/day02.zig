const std = @import("std");
const print = std.debug.print;

fn present_paper(dims: [3]usize) usize {
    var greatest = std.math.max(std.math.max(dims[0], dims[1]), dims[2]);
    var smallest_side = dims[0] * dims[1] * dims[2] / greatest;

    return smallest_side + 2 * dims[0] * dims[1] + 2 * dims[0] * dims[2] + 2 * dims[1] * dims[2];
}

fn present_ribbon(dims: [3]usize) usize {
    var cubic = dims[0] * dims[1] * dims[2];
    var greatest = std.math.max(std.math.max(dims[0], dims[1]), dims[2]);
    var smallest_perim = 2 * (dims[0] + dims[1] + dims[2] - greatest);

    return smallest_perim + cubic;
}

pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile(
        "./inputs/day02.txt",
        .{ .read = true },
    );

    var buffer: [1024]u8 = undefined;
    var bytes = try file.read(&buffer);

    var index: usize = 0;
    var lwh = [3]usize{ 0, 0, 0 };
    var paper_surface: usize = 0;
    var ribon_length: usize = 0;

    while (bytes > 0) {
        for (buffer[0..bytes]) |c| {
            switch (c) {
                'x' => {
                    index += 1;
                },
                '0'...'9' => {
                    lwh[index] *= 10;
                    lwh[index] += c - '0';
                },
                '\n' => {
                    paper_surface += present_paper(lwh);
                    ribon_length += present_ribbon(lwh);

                    index = 0;
                    lwh = [3]usize{ 0, 0, 0 };
                },
                else => @panic("Unexpected"),
            }
        }

        bytes = try file.read(&buffer);
    }

    print("Paper surface: {d}\n", .{paper_surface});
    print("Ribbon length: {d}\n", .{ribon_length});
}
