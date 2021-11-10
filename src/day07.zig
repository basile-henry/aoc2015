const std = @import("std");
const print = std.debug.print;

const Op = enum {
    AND,
    OR,
    LSHIFT,
    RSHIFT,
    NOT,
};

const Wire = union(enum) {
    name: [2]u8,
    constant: u16,
};

const Gate = struct {
    operands: [2]Wire,
    operand_count: u8,
    op: ?Op,
};

pub fn main() anyerror!void {
    const allocator = std.heap.page_allocator;

    var file = try std.fs.cwd().openFile(
        "./inputs/day07.txt",
        .{
            .read = true,
        },
    );

    var reader = std.io.bufferedReader(file.reader()).reader();
    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();

    var connections = std.AutoHashMap([2]u8, Gate).init(allocator);
    defer connections.deinit();

    while (reader.readUntilDelimiterArrayList(&line, '\n', 100)) {
        var tokens = std.mem.tokenize(u8, line.items, " ");

        var gate = Gate{
            .operands = undefined,
            .operand_count = 0,
            .op = null,
        };

        while (tokens.next()) |token| {
            if (std.mem.eql(u8, token, "->")) {
                break;
            } else if (std.mem.eql(u8, token, "AND")) {
                gate.op = Op.AND;
            } else if (std.mem.eql(u8, token, "OR")) {
                gate.op = Op.OR;
            } else if (std.mem.eql(u8, token, "LSHIFT")) {
                gate.op = Op.LSHIFT;
            } else if (std.mem.eql(u8, token, "RSHIFT")) {
                gate.op = Op.RSHIFT;
            } else if (std.mem.eql(u8, token, "NOT")) {
                gate.op = Op.NOT;
            } else if (std.ascii.isDigit(token[0])) {
                gate.operands[gate.operand_count] = Wire{ .constant = try std.fmt.parseInt(u16, token, 10) };
                gate.operand_count += 1;
            } else {
                var name = [2]u8{ 0, 0 };
                std.mem.copy(u8, &name, token);
                gate.operands[gate.operand_count] = Wire{ .name = name };
                gate.operand_count += 1;
            }
        }

        var key = [2]u8{ 0, 0 };
        std.mem.copy(u8, &key, tokens.next().?);

        try connections.put(key, gate);
    } else |err| {
        if (err != error.EndOfStream) {
            return err;
        }
    }

    const a_key = [2]u8{ 'a', 0 };

    // PART 1
    var resolved = try resolve(allocator, connections);

    const a = resolved.get(a_key).?;
    print("Part 1 | a: {d}\n", .{a});

    resolved.deinit();

    // PART 2
    const new_b = Gate{ .operands = [2]Wire{ Wire{ .constant = a }, undefined }, .operand_count = 1, .op = null };
    try connections.put([2]u8{ 'b', 0 }, new_b);

    resolved = try resolve(allocator, connections);

    const new_a = resolved.get(a_key).?;
    print("Part 2 | a: {d}\n", .{new_a});

    resolved.deinit();
}

fn resolve(allocator: *std.mem.Allocator, connections: std.AutoHashMap([2]u8, Gate)) anyerror!std.AutoHashMap([2]u8, u16) {
    var resolved = std.AutoHashMap([2]u8, u16).init(allocator);

    var todo = std.ArrayList([2]u8).init(allocator);
    defer todo.deinit();
    try todo.append([2]u8{ 'a', 0 });

    while (todo.popOrNull()) |name| {
        if (resolved.contains(name)) {
            continue;
        }

        const gate = connections.get(name).?;
        var resolved_operands: [2]u16 = undefined;
        var resolved_operand_count: u8 = 0;
        var un_resolved_operands: [2][2]u8 = undefined;
        var un_resolved_operand_count: u8 = 0;

        for (gate.operands[0..gate.operand_count]) |operand| {
            switch (operand) {
                Wire.constant => |c| {
                    resolved_operands[resolved_operand_count] = c;
                    resolved_operand_count += 1;
                },
                Wire.name => |n| {
                    if (resolved.get(n)) |v| {
                        resolved_operands[resolved_operand_count] = v;
                        resolved_operand_count += 1;
                    } else {
                        un_resolved_operands[un_resolved_operand_count] = n;
                        un_resolved_operand_count += 1;
                    }
                },
            }
        }

        if (un_resolved_operand_count > 0) {
            try todo.append(name);
            for (un_resolved_operands[0..un_resolved_operand_count]) |u| {
                try todo.append(u);
            }
        } else {
            if (gate.op) |op| {
                switch (op) {
                    Op.AND => {
                        std.debug.assert(resolved_operand_count == 2);
                        try resolved.put(name, resolved_operands[0] & resolved_operands[1]);
                    },
                    Op.OR => {
                        std.debug.assert(resolved_operand_count == 2);
                        try resolved.put(name, resolved_operands[0] | resolved_operands[1]);
                    },
                    Op.LSHIFT => {
                        std.debug.assert(resolved_operand_count == 2);
                        try resolved.put(name, resolved_operands[0] << @intCast(u4, resolved_operands[1]));
                    },
                    Op.RSHIFT => {
                        std.debug.assert(resolved_operand_count == 2);
                        try resolved.put(name, resolved_operands[0] >> @intCast(u4, resolved_operands[1]));
                    },
                    Op.NOT => {
                        std.debug.assert(resolved_operand_count == 1);
                        try resolved.put(name, ~resolved_operands[0]);
                    },
                }
            } else {
                std.debug.assert(resolved_operand_count == 1);
                try resolved.put(name, resolved_operands[0]);
            }
        }
    }

    return resolved;
}
