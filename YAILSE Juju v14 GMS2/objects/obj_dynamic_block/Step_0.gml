///Step

var _old_angle = image_angle;
image_angle -= 2;
if ( place_meeting( x, y, obj_player ) ) image_angle = _old_angle;