x = obj_player.x;
y = obj_player.y;
image_angle = point_direction( x, y, mouse_x, mouse_y );
if ( mouse_check_button_pressed( mb_right ) ) visible = !visible;
event_inherited();