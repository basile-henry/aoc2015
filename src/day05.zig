const std = @import("std");
const print = std.debug.print;

pub fn main() anyerror!void {
    const allocator = std.heap.page_allocator;

    var file = try std.fs.cwd().openFile(
        "./inputs/day05.txt",
        .{
            .read = true,
        },
    );

    var buf_file = std.io.bufferedReader(file.reader());
    var word_buffer = std.ArrayList(u8).init(allocator);
    defer word_buffer.deinit();

    var nice_1_words: usize = 0;
    var nice_2_words: usize = 0;

    while (true) {
        buf_file.reader().readUntilDelimiterArrayList(&word_buffer, '\n', 100) catch break;
        if (nice_1(word_buffer.items)) {
            nice_1_words += 1;
        }
        if (nice_2(word_buffer.items)) {
            nice_2_words += 1;
        }
    }

    print("Part 1 | Number of nice words: {d}\n", .{nice_1_words});
    print("Part 2 | Number of nice words: {d}\n", .{nice_2_words});
}

fn nice_1(str: []u8) bool {
    var vowel_count: usize = 0;
    var prev_letter: ?u8 = null;
    var at_least_one_repeat = false;

    for (str) |c| {
        switch (c) {
            'a', 'e', 'i', 'o', 'u' => vowel_count += 1,
            else => {},
        }

        if (prev_letter) |p| {
            if (p == c) {
                at_least_one_repeat = true;
            }

            if (p == 'a' and c == 'b') {
                return false;
            }
            if (p == 'c' and c == 'd') {
                return false;
            }
            if (p == 'p' and c == 'q') {
                return false;
            }
            if (p == 'x' and c == 'y') {
                return false;
            }
        }

        prev_letter = c;
    }

    return at_least_one_repeat and vowel_count >= 3;
}

fn contains(haystack: []u8, needle: []u8) bool {
    if (needle.len > haystack.len) {
        return false;
    }

    for (haystack) |_, i| {
        if (haystack.len - i < needle.len) {
            return false;
        }

        if (std.mem.eql(u8, haystack[i .. i + needle.len], needle)) {
            return true;
        }
    }

    return false;
}

fn nice_2(str: []u8) bool {
    var at_least_one_repeat = false;
    var at_least_one_pair = false;

    for (str) |_, i| {
        if (i + 3 < str.len) {
            if (contains(str[i + 2 ..], str[i .. i + 2])) {
                at_least_one_pair = true;
            }
        }

        if (i + 2 < str.len) {
            if (str[i] == str[i + 2]) {
                at_least_one_repeat = true;
            }
        }
    }

    return at_least_one_pair and at_least_one_repeat;
}
