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

    screen :: 200
    margin :: 20
    line_width :: 5
    c_radius :: line_width / 2
    line_length :: screen-2*margin-line_width
    other_margin :: screen-margin-line_width
    box_size :: screen-2*margin

    current_side := 0
    current_progress :f32 = 0.0
    overall_progress := 0.0

    overall_increment := 1.0/(60*minutes*FPS)

    main_color := rl.WHITE
    faded := rl.Color{100,100,100,255}
    overlay := rl.BLACK
    overlay.a = 0

    shadow_box :: rl.Rectangle{margin, margin, box_size, box_size}

    sides := [4]rl.Rectangle{
        rl.Rectangle{margin, margin, line_length, line_width},
        rl.Rectangle{other_margin, margin, line_width, line_length},
        rl.Rectangle{margin+line_width, other_margin, line_length, line_width},
        rl.Rectangle{margin, margin+line_width, line_width, line_length},
    }

    rl.InitWindow(screen,screen,"Box")
    rl.SetTargetFPS(60)

    for !rl.WindowShouldClose() && overall_progress < 1 {
        this := sides[current_side]

        switch current_side {
        case 0: this.width *= current_progress
        case 1: this.height *= current_progress
        case 2: {
            this.width *= min(current_progress, 1)
            this.x = other_margin - this.width + line_width
        }
        case 3: {
            this.height *= current_progress
            this.y = other_margin - this.height + line_width
        }
        }

        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)
        rl.DrawRectangleLinesEx(shadow_box, line_width, faded)
        for side in 0..<current_side do rl.DrawRectangleRec(sides[side], main_color)
        rl.DrawRectangleRec(this, main_color)
        rl.DrawRectangle(0,0,screen,screen,overlay)
        rl.EndDrawing()

        current_progress += 0.25/FPS
        overlay.a = u8(200.0*overall_progress)
        overall_progress += overall_increment

        if current_progress > 1 {
            current_progress = 0
            current_side += 1
        }
        current_side %= 4
    }

    rl.CloseWindow()
}
