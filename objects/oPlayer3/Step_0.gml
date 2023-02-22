//Player input
if (keyboard_check(vk_up   )) || (keyboard_check(ord("W"))) y -= 5;
if (keyboard_check(vk_down )) || (keyboard_check(ord("S"))) y += 5;
if (keyboard_check(vk_left )) || (keyboard_check(ord("A"))) x -= 5;
if (keyboard_check(vk_right)) || (keyboard_check(ord("D"))) x += 5;

//Update camera position
camera_set_view_pos(oRenderer3.camera,
                    round(x - 0.5*camera_get_view_width( oRenderer3.camera)),
                    round(y - 0.5*camera_get_view_height(oRenderer3.camera)));