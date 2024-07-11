const std = @import("std");
const rl = @import("raylib");
const Color = rl.Color;

pub fn main() anyerror!void {
    const screenWidth = 1280;
    const screenHeight = 720;

    rl.setConfigFlags(.{
        .msaa_4x_hint = true,
    });

    rl.initWindow(screenWidth, screenHeight, "particle-sim");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    // Main game loop
    while (!rl.windowShouldClose()) {
        // Update
        rl.drawCircle(screenWidth / 2, screenHeight / 2, 10, Color.red);

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(Color.black.brightness(0.1));
    }
}
