///Create

lighting_caster_create();

image_index = 0;
image_speed = 0;

//The (-0.5,-0.5) offset is a bit of a hack to stop self-lighting being too obviously flickery
var _l =  -sprite_get_width( sprite_index ) * 0.5 - 0.5;
var _t = -sprite_get_height( sprite_index ) * 0.5 - 0.5;
var _r =   sprite_get_width( sprite_index ) * 0.5 - 0.5;
var _b =  sprite_get_height( sprite_index ) * 0.5 - 0.5;

//Use clockwise definitions!
lighting_caster_add_geometry( _l, _t,   _r, _t ); //Top
lighting_caster_add_geometry( _r, _t,   _r, _b ); //Right
lighting_caster_add_geometry( _r, _b,   _l, _b ); //Bottom
lighting_caster_add_geometry( _l, _b,   _l, _t ); //Left