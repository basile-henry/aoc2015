const std = @import("std");
const print = std.debug.print;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var allocator = &gpa.allocator;

    var file = try std.fs.cwd().openFile(
        "./inputs/day17.txt",
        .{
            .read = true,
        },
    );

    var reader = std.io.bufferedReader(file.reader()).reader();
    var line_buffer: [4]u8 = undefined;
    var containers = std.ArrayList(usize).init(allocator);
    defer containers.deinit();

    while (try reader.readUntilDelimiterOrEof(&line_buffer, '\n')) |line| {
        try containers.append(try std.fmt.parseInt(usize, line, 10));
    }

    const count = ways(150, containers.items);
    print("Part 1: {d}\n", .{count});

    var counts = std.AutoHashMap(usize, usize).init(allocator);
    defer counts.deinit();

    try ways_container_count(&counts, 0, 150, containers.items);

    var min_count = containers.items.len;
    var counts_it = counts.keyIterator();
    while (counts_it.next()) |k| {
        min_count = std.math.min(min_count, k.*);
    }

    print("Part 2: {d}\n", .{counts.get(min_count).?});
}

fn ways(n: usize, containers: []usize) usize {
    if (n == 0) {
        return 1;
    }

    if (containers.len == 0) {
        return 0;
    }

    const head = containers[0];
    const tail = containers[1..];

    if (n >= head) {
        return ways(n - head, tail) + ways(n, tail);
    } else {
        return ways(n, tail);
    }
}

fn ways_container_count(c_counts: *std.AutoHashMap(usize, usize), c_count: usize, n: usize, containers: []usize) anyerror!void {
    if (n == 0) {
        if (c_counts.getPtr(c_count)) |w| {
            w.* += 1;
        } else {
            try c_counts.put(c_count, 1);
        }
        return;
    }

    if (containers.len == 0) {
        return;
    }

    const head = containers[0];
    const tail = containers[1..];

    if (n >= head) {
        try ways_container_count(c_counts, c_count + 1, n - head, tail);
    }

    try ways_container_count(c_counts, c_count, n, tail);
}
