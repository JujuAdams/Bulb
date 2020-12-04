bulb_set_as_occluder();

image_index = 0;
image_speed = 0;
image_angle = random(360);

var _l = -0.5*sprite_get_width(sprite_index);
var _t = -0.5*sprite_get_height(sprite_index);
var _r =  0.5*sprite_get_width(sprite_index);
var _b =  0.5*sprite_get_height(sprite_index);

//Use clockwise definitions!
bulb_occluder_add_geometry(_l, _t,   _r, _t); //Top
bulb_occluder_add_geometry(_r, _t,   _r, _b); //Right
bulb_occluder_add_geometry(_r, _b,   _l, _b); //Bottom
bulb_occluder_add_geometry(_l, _b,   _l, _t); //Left