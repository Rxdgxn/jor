package main

import "core:c"
import "core:fmt"
import rl "vendor:raylib"

snake: [dynamic]snake_part
snake_part :: struct {
    x, y, dx, dy: c.int,
}

WWIDTH :: 1000
WHEIGHT :: 600
SSIZE :: 20

init_snake :: proc(k: i32) {
    for i in 0 ..< k {
        append(&snake, snake_part {WWIDTH / 2 - k * SSIZE, WHEIGHT / 2, 1, 0})
    }
}

shift :: proc(new_head: snake_part) {
    new_snake: [dynamic]snake_part
    append(&new_snake, new_head)
    for i in 0 ..< len(snake) - 1 {
        append(&new_snake, snake[i])
    }
    snake = new_snake
}

main :: proc() {
    init_snake(5)
    rl.InitWindow(WWIDTH, WHEIGHT, "Jormungandr")
    rl.SetTargetFPS(15)
    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)

        for i in 0 ..< len(snake) {
            snake[i].x += snake[i].dx
            snake[i].y += snake[i].dy
        }
        for i in 0 ..< len(snake) {
            rl.DrawRectangle(snake[i].x, snake[i].y, SSIZE, SSIZE, rl.GREEN)
        }

        new_head := snake_part {snake[0].x + SSIZE * snake[0].dx, snake[0].y + SSIZE * snake[0].dy, snake[0].dx, snake[0].dy}
        if rl.IsKeyPressed(rl.KeyboardKey.W) {
            new_head.dx = 0
            new_head.dy = -1
        }
        else if rl.IsKeyPressed(rl.KeyboardKey.S) {
            new_head.dx = 0
            new_head.dy = 1
        }
        else if rl.IsKeyPressed(rl.KeyboardKey.A) {
            new_head.dx = -1
            new_head.dy = 0
        }
        else if rl.IsKeyPressed(rl.KeyboardKey.D) {
            new_head.dx = 1
            new_head.dy = 0
        }
        shift(new_head)

        rl.EndDrawing()
    }

    delete(snake)
    rl.CloseWindow()
}