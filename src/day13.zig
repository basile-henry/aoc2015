const std = @import("std");
const print = std.debug.print;

const Happiness = std.StringArrayHashMap(std.StringHashMap(isize));

pub fn main() anyerror!void {
    const global_allocator = std.heap.page_allocator;

    var file = try std.fs.cwd().openFile(
        "./inputs/day13.txt",
        .{
            .read = true,
        },
    );

    var reader = std.io.bufferedReader(file.reader()).reader();
    var line = std.ArrayList(u8).init(global_allocator);
    defer line.deinit();

    var happiness = Happiness.init(global_allocator);
    defer happiness.deinit();

    var arena = std.heap.ArenaAllocator.init(global_allocator);
    defer arena.deinit();

    var allocator = &arena.allocator;

    while (reader.readUntilDelimiterArrayList(&line, '\n', 1024)) {
        var tokens = std.mem.tokenize(u8, line.items, " ");

        const from = try std.mem.Allocator.dupe(allocator, u8, tokens.next().?);
        _ = tokens.next(); // would

        const gain_lose = tokens.next().?;
        const amount_str = tokens.next().?;
        var amount = try std.fmt.parseInt(isize, amount_str, 10);

        if (std.mem.eql(u8, gain_lose, "lose")) {
            amount = -amount;
        }

        _ = tokens.next(); // happiness
        _ = tokens.next(); // units
        _ = tokens.next(); // by
        _ = tokens.next(); // sitting
        _ = tokens.next(); // next
        _ = tokens.next(); // to

        const to_str = tokens.next().?;
        const to = try std.mem.Allocator.dupe(allocator, u8, to_str[0 .. to_str.len - 1]);

        if (happiness.getPtr(from)) |m| {
            try m.put(to, amount);
        } else {
            var m = std.StringHashMap(isize).init(allocator);
            try m.put(to, amount);
            try happiness.put(from, m);
        }
    } else |err| {
        if (err != error.EndOfStream) {
            return err;
        }
    }

    {
        const max_happiness = try maximum_happiness(global_allocator, happiness);

        print("Part 1: {d}\n", .{max_happiness});
    }

    {
        var me = std.StringHashMap(isize).init(allocator);
        var it = happiness.iterator();
        while (it.next()) |e| {
            try me.put(e.key_ptr.*, 0);
            try e.value_ptr.*.put("me", 0);
        }

        try happiness.put("me", me);

        const max_happiness = try maximum_happiness(global_allocator, happiness);

        print("Part 2: {d}\n", .{max_happiness});
    }
}

fn get_happiness(happiness: Happiness, arrangement: [][]const u8) isize {
    var sum: isize = 0;

    for (arrangement) |person, i| {
        const a = arrangement[if (i == 0) arrangement.len - 1 else (i - 1) % arrangement.len];
        const b = arrangement[(i + 1) % arrangement.len];

        const m = happiness.get(person).?;

        sum += m.get(a).?;
        sum += m.get(b).?;
    }

    return sum;
}

fn maximum_happiness(allocator: *std.mem.Allocator, happiness: Happiness) !isize {
    var people: [][]const u8 = try allocator.alloc([]const u8, happiness.count());
    defer allocator.free(people);

    for (happiness.keys()) |x, i| {
        people[i] = x;
    }

    var c: []usize = try allocator.alloc(usize, people.len);
    defer allocator.free(c);

    for (c) |*x| {
        x.* = 0;
    }

    var max_happiness: isize = 0;

    var i: usize = 0;
    while (i < people.len) {
        if (c[i] < i) {
            if (i % 2 == 0) {
                std.mem.swap([]const u8, &people[0], &people[i]);
            } else {
                std.mem.swap([]const u8, &people[c[i]], &people[i]);
            }

            max_happiness = std.math.max(max_happiness, get_happiness(happiness, people));

            c[i] += 1;
            i = 0;
        } else {
            c[i] = 0;
            i += 1;
        }
    }

    return max_happiness;
}
