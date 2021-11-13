const std = @import("std");
const print = std.debug.print;

pub fn main() anyerror!void {
    const allocator = std.heap.page_allocator;

    const input: []const u8 = "cqjxjnds";

    var current: []u8 = try allocator.alloc(u8, 8);

    std.mem.copy(u8, current, input);

    var password_count: usize = 0;

    outer: while (true) {
        var prev_letter: ?u8 = null;
        var is_increasing_straight_2 = false;
        var has_increasing_straight_3 = false;

        var in_pair = false;
        var pair_count: usize = 0;

        for (current) |c, i| {
            if (c == 'i' or c == 'o' or c == 'l') {
                next(&current[0 .. i + 1]);

                if (i < current.len - 1) {
                    for (current[i + 1 ..]) |*x| {
                        x.* = 'a';
                    }
                }

                continue :outer;
            }

            if (prev_letter) |p| {
                if (p == c and !in_pair) {
                    in_pair = true;
                    pair_count += 1;
                } else {
                    in_pair = false;
                }

                if (p + 1 == c) {
                    if (is_increasing_straight_2) {
                        has_increasing_straight_3 = true;
                    } else {
                        is_increasing_straight_2 = true;
                    }
                } else {
                    is_increasing_straight_2 = false;
                }
            }

            prev_letter = c;
        }

        if (has_increasing_straight_3 and pair_count >= 2) {
            password_count += 1;

            if (password_count == 1) {
                print("Part 1: {s}\n", .{current});
            } else if (password_count == 2) {
                print("Part 2: {s}\n", .{current});
                return;
            }

            next(&current);
        } else {
            next(&current);
        }
    }
}

fn next(input: *[]u8) void {
    var i: usize = input.len - 1;

    while (i >= 0) : (i -= 1) {
        if (input.*[i] == 'z') {
            input.*[i] = 'a';
        } else {
            input.*[i] += 1;
            return;
        }
    }
}
