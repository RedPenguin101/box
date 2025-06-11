package box

import "core:os"
import "core:strconv"
import rl "vendor:raylib"

main :: proc() {
    minutes:f64

    if len(os.args) == 2 {
        value, ok := strconv.parse_f64(os.args[1])
        if ok do minutes = value
        else do minutes = 2.0
    } else {
        minutes = 2.0
    }

    FPS :: 60

    screen       :: 200
    margin       :: 20
    line_width   :: 5
    line_length  :: screen - 2*margin - line_width
    other_margin :: screen -   margin - line_width
    box_size     :: screen - 2*margin

    current_side      :int
    current_progress  :f32
    current_increment :: 0.25/FPS

    overall_progress  :f64
    overall_increment := 1.0/(60*minutes*FPS)

    shadow_box :: rl.Rectangle{margin, margin, box_size, box_size}

    sides := [4]rl.Rectangle{
        rl.Rectangle{margin, margin, line_length, line_width},
        rl.Rectangle{other_margin, margin, line_width, line_length},
        rl.Rectangle{margin+line_width, other_margin, line_length, line_width},
        rl.Rectangle{margin, margin+line_width, line_width, line_length},
    }

    partial_side : rl.Rectangle

    main_color   :: rl.Color{255,255,255,255}
    shadow_color :: rl.Color{100,100,100,255}
    overlay_tint := rl.Color{0,0,0,0}

    rl.InitWindow(screen,screen,"Box")
    rl.SetTargetFPS(FPS)

    for !rl.WindowShouldClose() && overall_progress < 1 {
        partial_side = sides[current_side]

        switch current_side {
        case 0: partial_side.width *= current_progress
        case 1: partial_side.height *= current_progress
        case 2: {
            partial_side.width *= current_progress
            partial_side.x = other_margin - partial_side.width + line_width
        }
        case 3: {
            partial_side.height *= current_progress
            partial_side.y = other_margin - partial_side.height + line_width
        }
        }

        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)
        rl.DrawRectangleLinesEx(shadow_box, line_width, shadow_color)
        for side in 0..<current_side do rl.DrawRectangleRec(sides[side], main_color)
        rl.DrawRectangleRec(partial_side, main_color)
        rl.DrawRectangle(0,0,screen,screen,overlay_tint)
        rl.EndDrawing()

        current_progress += current_increment

        if current_progress > 1 {
            current_progress = 0
            current_side += 1
            current_side %= 4
        }

        overlay_tint.a = u8(200.0*overall_progress)
        overall_progress += overall_increment
    }

    rl.CloseWindow()
}
