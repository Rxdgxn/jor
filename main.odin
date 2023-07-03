package main

import "core:c"
import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:time"
import "core:strings"
import "core:strconv"
import rl "vendor:raylib"

snake: [dynamic]SnakePart
SnakePart :: struct {
    x, y: c.int,
}

WIN_WIDTH :: 600
WIN_HEIGHT :: 600
SNAKE_SIZE :: 20
FONT_SIZE :: SNAKE_SIZE
food_x, food_y: c.int

init_snake :: proc(k: i32) {
    for i in 0 ..< k {
        append(&snake, SnakePart {WIN_WIDTH / 2 - k * SNAKE_SIZE, WIN_HEIGHT / 2})
    }
}

spawn_food :: proc() {
    my_rand := rand.create(u64(time.now()._nsec))
    food_x = abs(i32(rand.uint64(&my_rand)) % (WIN_WIDTH - 2 * SNAKE_SIZE))
    food_x = (food_x / SNAKE_SIZE + 1) * SNAKE_SIZE
    food_y = abs(i32(rand.uint64(&my_rand)) % (WIN_HEIGHT - 2 * SNAKE_SIZE))
    food_y = (food_y / SNAKE_SIZE + 1) * SNAKE_SIZE
}
 
shift :: proc(new_head: SnakePart) {
    new_snake: [dynamic]SnakePart
    append(&new_snake, new_head)
    for i in 0 ..< len(snake) - 1 {
        append(&new_snake, snake[i])
    }
    snake = new_snake
}

distance :: proc() -> f32 {
    return math.sqrt_f32(f32((snake[0].x - food_x) * (snake[0].x - food_x) + (snake[0].y - food_y) * (snake[0].y - food_y)))
}

fit :: proc(val: ^c.int, limit: i32) {
    if val^ > limit - SNAKE_SIZE do val^ = 0
    else if val^ < 0 do val^ = limit
}

convert :: proc(x: i32) -> cstring {
    buf: [4]byte
    tmp := ""
    tmp = strings.concatenate({tmp, strconv.itoa(buf[:], int(x))})
    return strings.clone_to_cstring(tmp)
}

main :: proc() {
    dx, dy: c.int = 1, 0
    length: i32 = 1
    init_snake(length)
    spawn_food()
    over := false

    rl.InitWindow(WIN_WIDTH, WIN_HEIGHT, "Jormungandr")
    snake_piece := rl.LoadTexture("res/snake.png")
    food := rl.LoadTexture("res/food.png");
    rl.SetTargetFPS(15)

    for !rl.WindowShouldClose() && !over {
        rl.BeginDrawing()
        rl.ClearBackground(rl.GRAY)

        for i in 0 ..< len(snake) {
            fit(&snake[i].x, WIN_WIDTH)
            fit(&snake[i].y, WIN_HEIGHT)
            rl.DrawTexture(snake_piece, snake[i].x, snake[i].y, rl.WHITE)
        }

        new_head := SnakePart {snake[0].x + SNAKE_SIZE * dx, snake[0].y + SNAKE_SIZE * dy}
        if rl.IsKeyPressed(rl.KeyboardKey.W) {
            dx = 0
            dy = -1
        }
        else if rl.IsKeyPressed(rl.KeyboardKey.S) {
            dx = 0
            dy = 1
        }
        else if rl.IsKeyPressed(rl.KeyboardKey.A) {
            dx = -1
            dy = 0
        }
        else if rl.IsKeyPressed(rl.KeyboardKey.D) {
            dx = 1
            dy = 0
        }
        for i in 1 ..< len(snake) {
            if snake[i] == new_head {
                over = true
                break
            }
        }
        shift(new_head)

        rl.DrawTexture(food, food_x, food_y, rl.WHITE)
        if distance() < SNAKE_SIZE {
            length += 1
            spawn_food()
            append(&snake, snake[len(snake)-1])
        }

        rl.DrawText("LENGTH:", FONT_SIZE, FONT_SIZE, FONT_SIZE, rl.BLACK)
        rl.DrawText(convert(length), FONT_SIZE * 6, FONT_SIZE, FONT_SIZE, rl.BLACK)

        rl.EndDrawing()
    }

    delete(snake)
    rl.UnloadTexture(snake_piece)
    rl.UnloadTexture(food)
    rl.CloseWindow()
}