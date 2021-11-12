const std = @import("std");
const print = std.debug.print;

const Pos = struct { x: usize, y: usize };

const Grid = struct {
    allocator: *std.mem.Allocator,
    grid: *[1000][1000]bool,

    pub fn init(allocator: *std.mem.Allocator) !Grid {
        var grid = try allocator.create([1000][1000]bool);

        for (grid) |*row| {
            for (row) |*cell| {
                cell.* = false;
            }
        }

        return Grid{
            .allocator = allocator,
            .grid = grid,
        };
    }

    pub fn deinit(self: *Grid) void {
        self.allocator.free(self.grid);
        self.* = undefined;
    }

    pub fn on(self: Grid, low: Pos, high: Pos) void {
        var x = low.x;
        while (x <= high.x) : (x += 1) {
            var y = low.y;
            while (y <= high.y) : (y += 1) {
                self.grid[y][x] = true;
            }
        }
    }

    pub fn off(self: Grid, low: Pos, high: Pos) void {
        var x = low.x;
        while (x <= high.x) : (x += 1) {
            var y = low.y;
            while (y <= high.y) : (y += 1) {
                self.grid[y][x] = false;
            }
        }
    }

    pub fn toggle(self: Grid, low: Pos, high: Pos) void {
        var x = low.x;
        while (x <= high.x) : (x += 1) {
            var y = low.y;
            while (y <= high.y) : (y += 1) {
                self.grid[y][x] = !self.grid[y][x];
            }
        }
    }

    pub fn count_on(self: Grid) usize {
        var count: usize = 0;
        var x: usize = 0;
        while (x <= 999) : (x += 1) {
            var y: usize = 0;
            while (y <= 999) : (y += 1) {
                if (self.grid[y][x]) {
                    count += 1;
                }
            }
        }

        return count;
    }
};

const Grid2 = struct {
    allocator: *std.mem.Allocator,
    grid: *[1000][1000]usize,

    pub fn init(allocator: *std.mem.Allocator) !Grid2 {
        var grid = try allocator.create([1000][1000]usize);

        for (grid) |*row| {
            for (row) |*cell| {
                cell.* = 0;
            }
        }

        return Grid2{
            .allocator = allocator,
            .grid = grid,
        };
    }

    pub fn deinit(self: *Grid2) void {
        self.allocator.free(self.grid);
        self.* = undefined;
    }

    pub fn on(self: Grid2, low: Pos, high: Pos) void {
        var x = low.x;
        while (x <= high.x) : (x += 1) {
            var y = low.y;
            while (y <= high.y) : (y += 1) {
                self.grid[y][x] += 1;
            }
        }
    }

    pub fn off(self: Grid2, low: Pos, high: Pos) void {
        var x = low.x;
        while (x <= high.x) : (x += 1) {
            var y = low.y;
            while (y <= high.y) : (y += 1) {
                if (self.grid[y][x] > 0) {
                    self.grid[y][x] -= 1;
                }
            }
        }
    }

    pub fn toggle(self: Grid2, low: Pos, high: Pos) void {
        var x = low.x;
        while (x <= high.x) : (x += 1) {
            var y = low.y;
            while (y <= high.y) : (y += 1) {
                self.grid[y][x] += 2;
            }
        }
    }

    pub fn brightness(self: Grid2) usize {
        var brightness_amount: usize = 0;
        var x: usize = 0;
        while (x <= 999) : (x += 1) {
            var y: usize = 0;
            while (y <= 999) : (y += 1) {
                brightness_amount += self.grid[y][x];
            }
        }

        return brightness_amount;
    }
};

pub fn main() anyerror!void {
    const allocator = std.heap.page_allocator;

    var file = try std.fs.cwd().openFile(
        "./inputs/day06.txt",
        .{
            .read = true,
        },
    );

    var reader = std.io.bufferedReader(file.reader()).reader();
    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();

    var grid = try Grid.init(allocator);
    defer grid.deinit();

    var grid2 = try Grid2.init(allocator);
    defer grid2.deinit();

    while (reader.readUntilDelimiterArrayList(&line, '\n', 100)) {
        var tokens = std.mem.tokenize(u8, line.items, " ");

        var f: fn (Grid, Pos, Pos) void = undefined;
        var g: fn (Grid2, Pos, Pos) void = undefined;

        var t = tokens.next().?;
        if (std.mem.eql(u8, t, "toggle")) {
            f = Grid.toggle;
            g = Grid2.toggle;
        } else if (std.mem.eql(u8, t, "turn")) {
            var dir = tokens.next().?;
            if (std.mem.eql(u8, dir, "on")) {
                f = Grid.on;
                g = Grid2.on;
            } else if (std.mem.eql(u8, dir, "off")) {
                f = Grid.off;
                g = Grid2.off;
            }
        }

        var start: Pos = undefined;
        var start_token = tokens.next().?;

        {
            var it = std.mem.tokenize(u8, start_token, ",");
            start.x = try std.fmt.parseInt(usize, it.next().?, 10);
            start.y = try std.fmt.parseInt(usize, it.next().?, 10);
        }

        _ = tokens.next(); // through

        var end: Pos = undefined;
        var end_token = tokens.next().?;

        {
            var it = std.mem.tokenize(u8, end_token, ",");
            end.x = try std.fmt.parseInt(usize, it.next().?, 10);
            end.y = try std.fmt.parseInt(usize, it.next().?, 10);
        }

        f(grid, start, end);
        g(grid2, start, end);
    } else |err| {
        if (err != error.EndOfStream) {
            return err;
        }
    }

    print("Lights on: {d}\n", .{grid.count_on()});
    print("Brightness: {d}\n", .{grid2.brightness()});
}
