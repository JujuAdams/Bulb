light.x = obj_player.x;
light.y = obj_player.y;
light.angle = point_direction(obj_player.x, obj_player.y, mouse_x, mouse_y);

if (mouse_check_button_pressed(mb_right)) light.visible = !light.visible;