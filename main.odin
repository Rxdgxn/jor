package main

import "core:c"
import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:time"
import rl "vendor:raylib"

snake: [dynamic]SnakePart
SnakePart :: struct {
    x, y, dx, dy: c.int,
}

food: Food
Food :: struct {
    x, y: c.int,
}

WWIDTH :: 1000
WHEIGHT :: 600
SSIZE :: 20

init_snake :: proc(k: i32) {
    for i in 0 ..< k {
        append(&snake, SnakePart {WWIDTH / 2 - k * SSIZE, WHEIGHT / 2, 1, 0})
    }
}

spawn_food :: proc() {
    my_rand := rand.create(u64(time.now()._nsec))
    food.x = abs(i32(rand.uint64(&my_rand)) % WWIDTH)
    food.y = abs(i32(rand.uint64(&my_rand)) % WHEIGHT)
}
 
shift :: proc(new_head: SnakePart) {
    new_snake: [dynamic]SnakePart
    append(&new_snake, new_head)
    for i in 0 ..< len(snake) - 1 {
        append(&new_snake, snake[i])
    }
    snake = new_snake
}

distance :: proc(h: SnakePart, f: Food) -> f32 {
    return math.sqrt_f32(f32((h.x - f.x) * (h.x - f.x) + (h.y - f.y) * (h.y - f.y)))
}

main :: proc() {
    init_snake(5)
    spawn_food()

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

        new_head := SnakePart {snake[0].x + SSIZE * snake[0].dx, snake[0].y + SSIZE * snake[0].dy, snake[0].dx, snake[0].dy}
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

        rl.DrawRectangle(food.x, food.y, SSIZE - 5, SSIZE - 5, rl.RED)
        if distance(snake[0], food) < SSIZE do spawn_food() 

        rl.EndDrawing()
    }

    delete(snake)
    rl.CloseWindow()
}