//Player input
if (keyboard_check(vk_up   )) || (keyboard_check(ord("W"))) y -= 5;
if (keyboard_check(vk_down )) || (keyboard_check(ord("S"))) y += 5;
if (keyboard_check(vk_left )) || (keyboard_check(ord("A"))) x -= 5;
if (keyboard_check(vk_right)) || (keyboard_check(ord("D"))) x += 5;

//Update camera position
camera_set_view_pos(oRenderer4.camera,
                    round(x - 0.5*camera_get_view_width( oRenderer4.camera)),
                    round(y - 0.5*camera_get_view_height(oRenderer4.camera)));

//Make sure the light tracks the player
light.x = x;
light.y = y;
light.angle = point_direction(x, y, mouse_x, mouse_y);

//Allow the right mouse button to toggle the light
if (mouse_check_button_pressed(mb_right)) light.visible = !light.visible;