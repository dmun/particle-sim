const std = @import("std");
const sign = std.math.sign;
const rl = @import("raylib");
const gl = rl.gl;
const Vector2 = rl.Vector2;
const Color = rl.Color;

const GRAVITY = Vector2.init(0, -9.81);
const COLLISION_DAMPING = 0.7;

const Particle = struct {
    position: Vector2,
    force: Vector2,
    velocity: Vector2,
    mass: f32,
    radius: f32,
    color: Color,
    collision: bool = false,

    pub fn draw(self: *Particle) void {
        rl.drawCircleV(
            self.position,
            self.radius,
            if (self.collision) Color.red else self.color,
        );
        rl.drawLineV(self.position, self.position.add(self.force), Color.green);
        rl.drawLineV(self.position, self.position.add(self.velocity), Color.yellow);
    }
};

pub fn checkBox(p: *Particle) void {
    const size = 300;

    if (@abs(p.position.y) > size - p.radius) {
        p.force.x = 0;
        p.velocity.y = 0;
        p.position.y = (size - p.radius) * std.math.sign(p.position.y + size - p.radius);
    }

    if (@abs(p.position.x) > size - p.radius) {
        p.force.y = 0;
        p.velocity.x = 0;
        p.position.x = (size - p.radius) * std.math.sign(p.position.x + size - p.radius);
    }
}

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

    for (0..2) |ix| {
        for (0..2) |iy| {
            const diameter = 30;
            try particles.append(.{
                .position = Vector2.init(
                    @as(f32, @floatFromInt(ix)) * diameter,
                    @as(f32, @floatFromInt(iy)) * diameter,
                ),
                .force = Vector2.init(20, 50),
                .mass = 10,
                .velocity = Vector2.zero(),
                .radius = diameter / 2,
                .color = Color.blue,
            });
        }
    }

    var camera = rl.Camera2D{
        .zoom = 1,
        .offset = Vector2.init(screenWidth / 2, screenHeight / 2),
        .target = Vector2.init(0, 0),
        .rotation = 0,
    };

    // Main game loop
    while (!rl.windowShouldClose()) {
        // Input
        if (rl.isMouseButtonPressed(.mouse_button_left)) {
            const position = Vector2{
                .x = rl.getMousePosition().x - camera.offset.x,
                .y = screenHeight - rl.getMousePosition().y + camera.target.y,
            };
            const force = Vector2.init(@floatFromInt(rl.getRandomValue(-10, 10)), 20);
            try particles.append(.{
                .mass = 10,
                .radius = 20,
                .force = force,
                .velocity = force.scale(30),
                .color = Color.blue,
                .position = position,
                .collision = false,
            });
        }

        // Update
        for (particles.items) |*p| {
            p.force = p.force.add(GRAVITY.scale(p.mass));
            p.velocity = p.velocity.add(p.force.scale(p.mass).scale(rl.getFrameTime()));
            p.position = p.position.add(p.velocity.scale(rl.getFrameTime()));

            checkBox(p);

            var collision = false;
            for (particles.items) |*p2| {
                if (p.position.distance(p2.position) < p.radius + p2.radius) {
                    collision = true;

                    // p.velocity = p2.velocity.subtract(p.velocity);
                    // p2.velocity = p.velocity.subtract(p2.velocity);

                    // const n = p2.position.subtract(p.position);
                    // p.position = p.position.add(n.normalize().scale(p.radius + p2.radius));
                    // p2.position = p2.position.subtract(n.normalize().scale(p.radius + p2.radius));
                }
            }
            p.collision = collision;
        }

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();
        defer rl.drawFPS(0, 0);

        camera.begin();
        defer camera.end();

        gl.rlPushMatrix();
        defer gl.rlPopMatrix();
        gl.rlScalef(1, -1, 0);
        gl.rlDisableBackfaceCulling();

        rl.drawRectangle(-300, -300, 600, 600, Color.black);

        for (particles.items) |*p| {
            p.draw();
        }

        rl.clearBackground(Color.black.brightness(0.1));
    }
}
