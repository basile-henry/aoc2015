const std = @import("std");
const print = std.debug.print;

pub fn main() anyerror!void {
    const allocator = std.heap.page_allocator;

    var file = try std.fs.cwd().openFile(
        "./inputs/day08.txt",
        .{
            .read = true,
        },
    );

    var reader = std.io.bufferedReader(file.reader()).reader();
    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();

    var total_code_chars: usize = 0;
    var total_value_chars: usize = 0;
    var total_encode_chars: usize = 0;

    while (reader.readUntilDelimiterArrayList(&line, '\n', 100)) {
        const code_chars = line.items.len;
        var value_chars: usize = 0;
        var encode_chars: usize = 2;

        var escaped = false;
        var hex_rem: u8 = 0;

        for (line.items) |c| {
            if (hex_rem > 0) {
                hex_rem -= 1;
                continue;
            }

            switch (c) {
                '"' => {
                    encode_chars += 2;

                    if (escaped) {
                        value_chars += 1;
                        escaped = false;
                    }
                },
                '\\' => {
                    encode_chars += 2;

                    if (escaped) {
                        value_chars += 1;
                        escaped = false;
                    } else {
                        escaped = true;
                    }
                },
                'x' => {
                    encode_chars += 1;
                    value_chars += 1;

                    if (escaped) {
                        encode_chars += 2;
                        hex_rem = 2;
                        escaped = false;
                    }
                },
                else => {
                    encode_chars += 1;
                    value_chars += 1;
                },
            }
        }

        total_code_chars += code_chars;
        total_value_chars += value_chars;
        total_encode_chars += encode_chars;
    } else |err| {
        if (err != error.EndOfStream) {
            return err;
        }
    }

    print("Part 1: {d}\n", .{total_code_chars - total_value_chars});
    print("Part 2: {d}\n", .{total_encode_chars - total_code_chars});
}
