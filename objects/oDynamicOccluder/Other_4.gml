occluder       = BulbCreateDynamicOccluder(oRenderer.lighting);
occluder.x     = x;
occluder.y     = y;
occluder.angle = image_angle;

var _l = -0.5*sprite_get_width(sprite_index);
var _t = -0.5*sprite_get_height(sprite_index);
var _r =  0.5*sprite_get_width(sprite_index);
var _b =  0.5*sprite_get_height(sprite_index);

//Use clockwise definitions!
occluder.add_edge(_l, _t, _r, _t); //Top
occluder.add_edge(_r, _t, _r, _b); //Right
occluder.add_edge(_r, _b, _l, _b); //Bottom
occluder.add_edge(_l, _b, _l, _t); //Left