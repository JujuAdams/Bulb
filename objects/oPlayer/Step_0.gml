//Player input
if (keyboard_check(vk_up   )) || (keyboard_check(ord("W"))) y -= 5;
if (keyboard_check(vk_down )) || (keyboard_check(ord("S"))) y += 5;
if (keyboard_check(vk_left )) || (keyboard_check(ord("A"))) x -= 5;
if (keyboard_check(vk_right)) || (keyboard_check(ord("D"))) x += 5;

//Shooting
if (mouse_check_button(mb_left) and (alarm_get(0) <= 0))
{
    alarm_set(0, 12);
    
    var _inst = instance_create_depth(x, y, 0, oLightPlasma);
    with(_inst)
    {
        speed = 10;
        direction = point_direction(x, y, mouse_x, mouse_y) + random_range(-5, 5);
        image_angle = direction;
    }
}

//Update camera position
camera_set_view_pos(oRenderer.camera,
                    round(x - 0.5*camera_get_view_width( oRenderer.camera)),
                    round(y - 0.5*camera_get_view_height(oRenderer.camera)));

//Make sure the light tracks the player
light.x = x;
light.y = y;
light.angle = point_direction(x, y, mouse_x, mouse_y);

//Allow the right mouse button to toggle the light
if (mouse_check_button_pressed(mb_right)) light.visible = !light.visible;

visionCone.x = x;
visionCone.y = y;
visionCone.angle = point_direction(x, y, mouse_x, mouse_y);