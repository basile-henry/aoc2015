const std = @import("std");
const print = std.debug.print;

const Ingredient = struct {
    capacity: isize,
    durability: isize,
    flavor: isize,
    texture: isize,
    calories: isize,
};

pub fn main() anyerror!void {
    const global_allocator = std.heap.page_allocator;

    var file = try std.fs.cwd().openFile(
        "./inputs/day15.txt",
        .{
            .read = true,
        },
    );

    var reader = std.io.bufferedReader(file.reader()).reader();
    var line_buffer: [1024]u8 = undefined;

    var ingredients = std.ArrayList(Ingredient).init(global_allocator);
    defer ingredients.deinit();

    while (try reader.readUntilDelimiterOrEof(&line_buffer, '\n')) |line| {
        var tokens = std.mem.tokenize(u8, line, " ");

        _ = tokens.next(); // <name>:

        _ = tokens.next(); // capacity
        const capacity_str = tokens.next().?;
        const capacity = try std.fmt.parseInt(isize, capacity_str[0 .. capacity_str.len - 1], 10);

        _ = tokens.next(); // durability
        const durability_str = tokens.next().?;
        const durability = try std.fmt.parseInt(isize, durability_str[0 .. durability_str.len - 1], 10);

        _ = tokens.next(); // flavor
        const flavor_str = tokens.next().?;
        const flavor = try std.fmt.parseInt(isize, flavor_str[0 .. flavor_str.len - 1], 10);

        _ = tokens.next(); // texture
        const texture_str = tokens.next().?;
        const texture = try std.fmt.parseInt(isize, texture_str[0 .. texture_str.len - 1], 10);

        _ = tokens.next(); // calories
        const calories_str = tokens.next().?;
        const calories = try std.fmt.parseInt(isize, calories_str, 10);

        const ingredient = Ingredient{
            .capacity = capacity,
            .durability = durability,
            .flavor = flavor,
            .texture = texture,
            .calories = calories,
        };

        try ingredients.append(ingredient);
    }

    {
        var vector = std.ArrayList(isize).init(global_allocator);
        defer vector.deinit();

        var best_score: isize = 0;
        try find_best_score(vector, ingredients.items, &best_score, null);

        print("Part 1: {d}\n", .{best_score});
    }

    {
        var vector = std.ArrayList(isize).init(global_allocator);
        defer vector.deinit();

        var best_score: isize = 0;
        try find_best_score(vector, ingredients.items, &best_score, 500);

        print("Part 2: {d}\n", .{best_score});
    }
}

fn find_best_score(
    candidate: std.ArrayList(isize),
    ingredients: []Ingredient,
    best_score: *isize,
    calories_goal: ?isize,
) anyerror!void {
    if (ingredients.len == candidate.items.len) {
        if (sum(candidate.items) != 100) {
            std.debug.panic("Wrong sum: {d}\n", .{sum(candidate.items)});
        }

        const out = get_score(candidate.items, ingredients);

        if (calories_goal) |goal| {
            if (goal != out.calories) {
                return;
            }
        }

        best_score.* = std.math.max(best_score.*, out.score);
    } else if (ingredients.len - 1 == candidate.items.len) {
        const s = sum(candidate.items);

        var c = candidate;
        try c.append(100 - s);
        defer _ = c.pop();

        try find_best_score(c, ingredients, best_score, calories_goal);
    } else {
        const s = sum(candidate.items);

        var c = candidate;

        var i: isize = 0;
        while (i < 100 - s) : (i += 1) {
            try c.append(i);
            defer _ = c.pop();

            try find_best_score(c, ingredients, best_score, calories_goal);
        }
    }
}

fn sum(xs: []isize) isize {
    var s: isize = 0;

    for (xs) |x| {
        s += x;
    }

    return s;
}

fn get_score(xs: []isize, ingredients: []Ingredient) struct { score: isize, calories: isize } {
    var sum_ingredient = Ingredient{
        .capacity = 0,
        .durability = 0,
        .flavor = 0,
        .texture = 0,
        .calories = 0,
    };

    for (ingredients) |ingredient, i| {
        sum_ingredient.capacity += ingredient.capacity * xs[i];
        sum_ingredient.durability += ingredient.durability * xs[i];
        sum_ingredient.flavor += ingredient.flavor * xs[i];
        sum_ingredient.texture += ingredient.texture * xs[i];
        sum_ingredient.calories += ingredient.calories * xs[i];
    }

    var product: isize = 1;

    product *= std.math.max(0, sum_ingredient.capacity);
    product *= std.math.max(0, sum_ingredient.durability);
    product *= std.math.max(0, sum_ingredient.flavor);
    product *= std.math.max(0, sum_ingredient.texture);

    return .{ .score = product, .calories = sum_ingredient.calories };
}
