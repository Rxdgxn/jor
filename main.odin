package main

// Dependencies
import "core:c"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

// Permutations
stack: [10]int
N :: 3
perms: [dynamic]cstring

ret_perm :: proc(k: int) -> cstring {
    tmp: string = ""
    for i := 1; i <= N; i += 1 {
        tmp = strings.concatenate({tmp, strconv.itoa([]u8{0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, stack[i])})
    }
    return strings.clone_to_cstring(tmp)
}

solution :: proc(k: int) -> bool {
    return k == N
}

valid :: proc(k: int) -> bool {
    for i := 1; i < k; i += 1 {
        if stack[i] == stack[k] {
            return false
        }
    }
    return true
}

back :: proc(k: int) {

    for i := 1; i <= N; i += 1 {
        stack[k] = i;
        if valid(k) {
            if solution(k) {
                append(&perms, ret_perm(k))
            }
            else do back(k + 1)
        }
    }
}

// Entry point
main :: proc() {

    FONT_SIZE  :: 60
    FONT_COLOR :: rl.GRAY
    rl.InitWindow(800, 450, "Odin Test")

    back(1)

    for !rl.WindowShouldClose() {
        posX: c.int = 345
        posY: c.int = 50

        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        
        for i := 0; i < len(perms); i += 1 {
            rl.DrawText(perms[i], posX, posY + FONT_SIZE * cast(i32)i, FONT_SIZE, FONT_COLOR)
        }

        rl.EndDrawing()
    }

    rl.CloseWindow()
}