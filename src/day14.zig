const std = @import("std");
const print = std.debug.print;

pub fn main() anyerror!void {
    const global_allocator = std.heap.page_allocator;

    var file = try std.fs.cwd().openFile(
        "./inputs/day14.txt",
        .{
            .read = true,
        },
    );

    var reader = std.io.bufferedReader(file.reader()).reader();
    var line = std.ArrayList(u8).init(global_allocator);
    defer line.deinit();

    const ReindeerState = union(enum) {
        at_rest_since: usize,
        in_movement_since: usize,
    };
    const Reindeer = struct {
        speed: usize,
        movement_duration: usize,
        rest_duration: usize,
        score: usize,
        distance: usize,
        state: ReindeerState,
    };

    var reindeers = std.ArrayList(Reindeer).init(global_allocator);
    defer reindeers.deinit();

    const duration_goal: usize = 2503;
    var max_distance: usize = 0;

    while (reader.readUntilDelimiterArrayList(&line, '\n', 1024)) {
        var tokens = std.mem.tokenize(u8, line.items, " ");

        _ = tokens.next(); // <name>
        _ = tokens.next(); // can
        _ = tokens.next(); // fly

        const speed_str = tokens.next().?;
        const speed = try std.fmt.parseInt(usize, speed_str, 10);

        _ = tokens.next(); // km/s
        _ = tokens.next(); // for

        const movement_duration_str = tokens.next().?;
        const movement_duration = try std.fmt.parseInt(usize, movement_duration_str, 10);

        _ = tokens.next(); // seconds,
        _ = tokens.next(); // but
        _ = tokens.next(); // then
        _ = tokens.next(); // must
        _ = tokens.next(); // rest
        _ = tokens.next(); // for

        const rest_duration_str = tokens.next().?;
        const rest_duration = try std.fmt.parseInt(usize, rest_duration_str, 10);

        try reindeers.append(Reindeer{
            .speed = speed,
            .movement_duration = movement_duration,
            .rest_duration = rest_duration,
            .score = 0,
            .distance = 0,
            .state = ReindeerState{
                .in_movement_since = 0,
            },
        });

        var distance: usize = 0;
        var duration: usize = 0;

        while (duration < duration_goal) {
            { // movement
                var d = std.math.min(movement_duration, duration_goal - duration);
                distance += speed * d;
                duration += d;
            }

            { // rest
                var d = std.math.min(rest_duration, duration_goal - duration);
                duration += d;
            }
        }

        max_distance = std.math.max(max_distance, distance);
    } else |err| {
        if (err != error.EndOfStream) {
            return err;
        }
    }

    print("Part 1: {d}\n", .{max_distance});

    var seconds: usize = 1;
    while (seconds <= duration_goal) : (seconds += 1) {
        var best_distance_so_far: usize = 0;

        for (reindeers.items) |*r| {
            switch (r.state) {
                .at_rest_since => |t| {
                    if (t + r.rest_duration == seconds) {
                        r.state = ReindeerState{ .in_movement_since = seconds };
                    }
                },
                .in_movement_since => |t| {
                    if (t + r.movement_duration == seconds) {
                        r.state = ReindeerState{ .at_rest_since = seconds };
                    }

                    r.distance += r.speed;
                },
            }

            best_distance_so_far = std.math.max(best_distance_so_far, r.distance);
        }

        for (reindeers.items) |*r| {
            if (r.distance == best_distance_so_far) {
                r.score += 1;
            }
        }
    }

    var best_score: usize = 0;
    for (reindeers.items) |r| {
        best_score = std.math.max(best_score, r.score);
    }

    print("Part 2: {d}\n", .{best_score});
}
