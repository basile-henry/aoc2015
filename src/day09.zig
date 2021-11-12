const std = @import("std");
const print = std.debug.print;

const Distances = std.StringHashMap(std.StringHashMap(usize));

pub fn main() anyerror!void {
    const global_allocator = std.heap.page_allocator;

    var file = try std.fs.cwd().openFile(
        "./inputs/day09.txt",
        .{
            .read = true,
        },
    );

    var reader = std.io.bufferedReader(file.reader()).reader();
    var line = std.ArrayList(u8).init(global_allocator);
    defer line.deinit();

    var distances = Distances.init(global_allocator);
    defer distances.deinit();

    var arena = std.heap.ArenaAllocator.init(global_allocator);
    defer arena.deinit();

    var allocator = &arena.allocator;

    while (reader.readUntilDelimiterArrayList(&line, '\n', 100)) {
        var tokens = std.mem.tokenize(u8, line.items, " ");

        const from = try std.mem.Allocator.dupe(allocator, u8, tokens.next().?);
        _ = tokens.next();

        const to = try std.mem.Allocator.dupe(allocator, u8, tokens.next().?);
        _ = tokens.next();

        const distance = try std.fmt.parseInt(usize, tokens.next().?, 10);

        if (distances.getPtr(from)) |m| {
            try m.put(to, distance);
        } else {
            var m = std.StringHashMap(usize).init(allocator);
            try m.put(to, distance);
            try distances.put(from, m);
        }

        if (distances.getPtr(to)) |m| {
            try m.put(from, distance);
        } else {
            var m = std.StringHashMap(usize).init(allocator);
            try m.put(from, distance);
            try distances.put(to, m);
        }
    } else |err| {
        if (err != error.EndOfStream) {
            return err;
        }
    }

    var so_far = std.StringArrayHashMap(void).init(global_allocator);
    defer so_far.deinit();

    const shortest = try shortest_path(false, distances, so_far, 0);

    print("Part 1: {d}\n", .{shortest});

    so_far.clearRetainingCapacity();

    const longest = try shortest_path(true, distances, so_far, 0);

    print("Part 2: {d}\n", .{longest});
}

fn shortest_path(longest: bool, distances: Distances, so_far_const: std.StringArrayHashMap(void), distance_so_far: usize) anyerror!usize {
    var so_far = try so_far_const.clone();
    defer so_far.deinit();

    var keys = distances.keyIterator();
    var best_route: ?usize = null;
    var current_distances: ?*std.StringHashMap(usize) = null;

    if (so_far.popOrNull()) |current| {
        try so_far.put(current.key, .{});
        current_distances = distances.getPtr(current.key).?;
    }

    while (keys.next()) |k| {
        if (!so_far.contains(k.*)) {
            try so_far.put(k.*, .{});
            defer _ = so_far.pop();

            var d_so_far = distance_so_far;

            if (current_distances) |d| {
                d_so_far += d.get(k.*).?;
            }

            const distance = try shortest_path(longest, distances, so_far, d_so_far);

            if (best_route) |r| {
                if (longest and distance > r) {
                    best_route = distance;
                } else if (!longest and distance < r) {
                    best_route = distance;
                }
            } else {
                best_route = distance;
            }
        }
    }

    if (best_route) |s| {
        return s;
    } else {
        return distance_so_far;
    }
}
