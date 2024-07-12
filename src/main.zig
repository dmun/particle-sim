const std = @import("std");
const rl = @import("raylib");
const Vector2 = rl.Vector2;
const Color = rl.Color;

const gravity = 300;
const collisionDamping = 0.7;

const Particle = struct {
    position: Vector2,
    velocity: Vector2,
};

pub fn main() anyerror!void {
    const screenWidth = 1280;
    const screenHeight = 720;

    rl.setConfigFlags(.{
        .msaa_4x_hint = true,
    });

    rl.initWindow(screenWidth, screenHeight, "particle-sim");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    const allocator = std.heap.page_allocator;
    var particles = std.ArrayList(Particle).init(allocator);

    for (0..20) |ix| {
        for (0..20) |iy| {
            try particles.append(.{
                .position = Vector2.init(
                    screenWidth / 3 + @as(f32, @floatFromInt(ix)) * 20,
                    screenHeight / 3 + @as(f32, @floatFromInt(iy)) * 20,
                ),
                .velocity = Vector2.zero(),
            });
        }
    }

    // Main game loop
    while (!rl.windowShouldClose()) {
        // Update
        const frametime = rl.getFrameTime();

        for (particles.items) |*p| {
            p.velocity = Vector2
                .init(0, 1)
                .scale(gravity)
                .scale(frametime)
                .add(p.velocity);

            p.position = p.velocity
                .scale(frametime)
                .add(p.position);

            if (@abs(p.position.x) > screenWidth) {
                p.position.x = screenWidth * std.math.sign(p.position.x);
                p.velocity.x *= -1 * collisionDamping;
            }

            if (@abs(p.position.y) > screenHeight) {
                p.position.y = screenHeight * std.math.sign(p.position.y);
                p.velocity.y *= -1 * collisionDamping;
            }
        }

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        for (particles.items) |*p| {
            rl.drawCircleV(p.position, 10, Color.red);
        }

        rl.clearBackground(Color.black.brightness(0.1));
    }
}
