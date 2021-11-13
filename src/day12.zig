const std = @import("std");
const print = std.debug.print;

pub fn main() anyerror!void {
    const allocator = std.heap.page_allocator;

    var file = try std.fs.cwd().openFile(
        "./inputs/day12.txt",
        .{
            .read = true,
        },
    );

    var reader = std.io.bufferedReader(file.reader()).reader();

    try part1(@TypeOf(reader), allocator, reader);

    try file.seekTo(0);

    try part2(@TypeOf(reader), allocator, reader);
}

fn part1(comptime Reader: type, allocator: *std.mem.Allocator, reader: Reader) !void {
    var number = std.ArrayList(u8).init(allocator);
    defer number.deinit();

    var sum: isize = 0;

    while (reader.readByte()) |c| {
        if (std.ascii.isDigit(c) or (c == '-' and number.items.len == 0)) {
            try number.append(c);
        } else if (number.items.len > 0) {
            sum += try std.fmt.parseInt(isize, number.items, 10);

            number.clearRetainingCapacity();
        }
    } else |err| {
        if (err != error.EndOfStream) {
            return err;
        }
    }

    print("Part 1: {d}\n", .{sum});
}

fn part2(comptime Reader: type, allocator: *std.mem.Allocator, reader: Reader) !void {
    var json = std.ArrayList(u8).init(allocator);
    defer json.deinit();
    try reader.readAllArrayList(&json, 50_000);

    var parser = std.json.Parser.init(allocator, false);
    defer parser.deinit();

    var value_tree = try parser.parse(json.items);
    defer value_tree.deinit();

    var todo = std.ArrayList(std.json.Value).init(allocator);
    defer todo.deinit();

    try todo.append(value_tree.root);

    var sum: i64 = 0;

    while (todo.popOrNull()) |node| {
        switch (node) {
            .Null => {},
            .Bool => {},
            .Integer => |x| {
                sum += x;
            },
            .Float => |_| unreachable,
            .NumberString => |_| unreachable,
            .String => |_| {},
            .Array => |nodes| {
                try todo.appendSlice(nodes.items);
            },
            .Object => |map| {
                var candidates = std.ArrayList(std.json.Value).init(allocator);
                defer candidates.deinit();

                var is_red = false;

                for (map.values()) |v| {
                    if (v == .String) {
                        if (std.mem.eql(u8, v.String, "red")) {
                            is_red = true;
                            break;
                        }
                    }

                    try candidates.append(v);
                }

                if (!is_red) {
                    try todo.appendSlice(candidates.items);
                }
            },
        }
    }

    print("Part 2: {d}\n", .{sum});
}
