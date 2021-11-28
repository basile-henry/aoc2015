const std = @import("std");
const print = std.debug.print;

const SIZE = 100;
const Grid = std.ArrayList([SIZE]u8);

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var allocator = &gpa.allocator;

    var file = try std.fs.cwd().openFile(
        "./inputs/day18.txt",
        .{
            .read = true,
        },
    );

    var reader = std.io.bufferedReader(file.reader()).reader();
    var grid = try Grid.initCapacity(allocator, SIZE);
    defer grid.deinit();

    var grid2 = try Grid.initCapacity(allocator, SIZE);
    defer grid2.deinit();

    var other = try Grid.initCapacity(allocator, SIZE);
    defer other.deinit();

    var r: usize = 0;
    while (r < SIZE) : (r += 1) {
        var row: [SIZE]u8 = undefined;
        _ = try reader.readAll(&row);
        _ = try reader.readByte();
        try grid.append(row);
        try grid2.append(row);
        try other.append(undefined);
    }

    {
        var i: usize = 0;
        while (i < SIZE) : (i += 1) {
            step(grid, &other);
            std.mem.swap(Grid, &grid, &other);
        }

        print("Part 1: {d}\n", .{alive(grid)});
    }

    {
        var i: usize = 0;
        while (i < SIZE) : (i += 1) {
            grid2.items[0][0] = '#';
            grid2.items[0][SIZE - 1] = '#';
            grid2.items[SIZE - 1][0] = '#';
            grid2.items[SIZE - 1][SIZE - 1] = '#';

            step(grid2, &other);
            std.mem.swap(Grid, &grid2, &other);
        }

        grid2.items[0][0] = '#';
        grid2.items[0][SIZE - 1] = '#';
        grid2.items[SIZE - 1][0] = '#';
        grid2.items[SIZE - 1][SIZE - 1] = '#';

        print("Part 2: {d}\n", .{alive(grid2)});
    }
}

fn step(grid: Grid, next: *Grid) void {
    var i: usize = 0;
    while (i < SIZE) : (i += 1) {
        var j: usize = 0;
        while (j < SIZE) : (j += 1) {
            var n: usize = 0;

            const li = if (i == 0) 0 else i - 1;
            const hi = if (i == SIZE - 1) SIZE - 1 else i + 1;
            const lj = if (j == 0) 0 else j - 1;
            const hj = if (j == SIZE - 1) SIZE - 1 else j + 1;

            var x = li;
            while (x <= hi) : (x += 1) {
                var y = lj;
                while (y <= hj) : (y += 1) {
                    if (x != i or y != j) {
                        n += if (grid.items[y][x] == '#') @as(usize, 1) else 0;
                    }
                }
            }

            if (grid.items[j][i] == '#') {
                next.items[j][i] = if (n == 2 or n == 3) '#' else '.';
            } else {
                next.items[j][i] = if (n == 3) '#' else '.';
            }
        }
    }
}

fn alive(grid: Grid) usize {
    var count: usize = 0;

    for (grid.items) |row| {
        for (row) |cell| {
            if (cell == '#') {
                count += 1;
            }
        }
    }

    return count;
}
