const std = @import("std");
const print = std.debug.print;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var allocator = &gpa.allocator;

    var file = try std.fs.cwd().openFile(
        "./inputs/day16.txt",
        .{
            .read = true,
        },
    );

    var reader = std.io.bufferedReader(file.reader()).reader();
    var line_buffer: [1024]u8 = undefined;

    var attrs = std.StringHashMap(usize).init(allocator);
    defer attrs.deinit();

    try attrs.put("children", 3);
    try attrs.put("cats", 7);
    try attrs.put("samoyeds", 2);
    try attrs.put("pomeranians", 3);
    try attrs.put("akitas", 0);
    try attrs.put("vizslas", 0);
    try attrs.put("goldfish", 5);
    try attrs.put("trees", 3);
    try attrs.put("cars", 2);
    try attrs.put("perfumes", 1);

    line: while (try reader.readUntilDelimiterOrEof(&line_buffer, '\n')) |line| {
        var tokens = std.mem.tokenize(u8, line, " ");

        _ = tokens.next(); // Sue

        const number = try parseInt(tokens.next().?);

        while (tokens.next()) |key| {
            const val = try parseInt(tokens.next().?);

            if (attrs.get(std.mem.trimRight(u8, key, ":"))) |v| {
                if (val != v) {
                    continue :line;
                }
            }
        }

        print("Part 1: {d}\n", .{number});
        break;
    }

    try file.seekTo(0);
    reader = std.io.bufferedReader(file.reader()).reader();

    line: while (try reader.readUntilDelimiterOrEof(&line_buffer, '\n')) |line| {
        var tokens = std.mem.tokenize(u8, line, " ");

        _ = tokens.next(); // Sue

        const number = try parseInt(tokens.next().?);

        while (tokens.next()) |key| {
            const val = try parseInt(tokens.next().?);

            const k = std.mem.trimRight(u8, key, ":");

            if (attrs.get(k)) |v| {
                if (std.mem.eql(u8, "cats", k) or std.mem.eql(u8, "trees", k)) {
                    if (val <= v) {
                        continue :line;
                    }
                } else if (std.mem.eql(u8, "pomeranians", k) or std.mem.eql(u8, "goldfish", k)) {
                    if (val >= v) {
                        continue :line;
                    }
                } else if (val != v) {
                    continue :line;
                }
            }
        }

        print("Part 2: {d}\n", .{number});
        break;
    }
}

fn parseInt(token: []const u8) !usize {
    return std.fmt.parseInt(usize, std.mem.trimRight(u8, token, ":,"), 10);
}
