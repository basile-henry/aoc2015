const std = @import("std");
const print = std.debug.print;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var allocator = &gpa.allocator;
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    var file = try std.fs.cwd().openFile(
        "./inputs/day19.txt",
        .{
            .read = true,
        },
    );

    var reader = std.io.bufferedReader(file.reader()).reader();
    var line_buffer: [1024]u8 = undefined;
    var done = false;
    var start_molecule: []u8 = undefined;

    var replacements = std.ArrayList(struct { key: []u8, value: []u8 }).init(allocator);
    defer replacements.deinit();

    var made_from = std.StringHashMap([]u8).init(allocator);
    defer made_from.deinit();

    while (try reader.readUntilDelimiterOrEof(&line_buffer, '\n')) |line| {
        if (done) {
            start_molecule = line;
            break;
        }

        if (line.len == 0) {
            done = true;
            continue;
        }

        var tokens = std.mem.tokenize(u8, line, " ");
        const key = try arena.allocator.dupe(u8, tokens.next().?);
        _ = tokens.next();
        const val = try arena.allocator.dupe(u8, tokens.next().?);

        try replacements.append(.{ .key = key, .value = val });
        try made_from.put(val, key);
    }

    var molecules = std.StringHashMap(usize).init(allocator);
    defer molecules.deinit();

    for (replacements.items) |r| {
        const k = r.key;
        const v = r.value;

        for (start_molecule) |_, i| {
            if (i + k.len <= start_molecule.len) {
                if (std.mem.eql(u8, k, start_molecule[i .. i + k.len])) {
                    var new = std.ArrayList(u8).init(&arena.allocator);

                    if (i > 0) {
                        try new.appendSlice(start_molecule[0..i]);
                    }
                    try new.appendSlice(v);
                    try new.appendSlice(start_molecule[i + k.len ..]);

                    if (molecules.getPtr(new.items)) |p| {
                        p.* += 1;
                    } else {
                        try molecules.put(new.items, 1);
                    }
                }
            } else {
                break;
            }
        }
    }

    print("Part 1: {d}\n", .{molecules.count()});

    var step_count = (try min_steps(allocator, made_from, start_molecule, 0)).?;
    print("Part 2: {d}\n", .{step_count});
}

fn min_steps(allocator: *std.mem.Allocator, made_from: std.StringHashMap([]u8), start_molecule: []u8, num_steps: usize) anyerror!?usize {
    if (std.mem.eql(u8, "e", start_molecule)) {
        return num_steps;
    }

    var min: ?usize = null;

    for (start_molecule) |_, l| {
        const i = start_molecule.len - 1 - l;

        var it = made_from.iterator();

        while (it.next()) |from| {
            const k = from.key_ptr.*;
            if (i + k.len <= start_molecule.len and std.mem.eql(u8, k, start_molecule[i .. i + k.len])) {
                var molecule = std.ArrayList(u8).init(allocator);
                defer molecule.deinit();

                try molecule.appendSlice(start_molecule);
                try molecule.replaceRange(i, k.len, from.value_ptr.*);

                if (try min_steps(allocator, made_from, molecule.items, num_steps + 1)) |n| {
                    if (min) |m| {
                        min = std.math.min(m, n);
                    } else {
                        min = n;
                    }

                    return min; // Hack: it takes too long to find shorter ones
                }
            }
        }
    }

    return min;
}
