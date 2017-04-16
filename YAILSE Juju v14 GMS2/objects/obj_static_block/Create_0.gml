///Create

lighting_caster_create();

image_index = 0;
image_speed = 0;

//The (-0.5,-0.5) offset is a bit of a hack to stop self-lighting being too obviously flickery
var _l =  -sprite_get_width( sprite_index ) * 0.5 - 0.5;
var _t = -sprite_get_height( sprite_index ) * 0.5 - 0.5;
var _r =   sprite_get_width( sprite_index ) * 0.5 - 0.5;
var _b =  sprite_get_height( sprite_index ) * 0.5 - 0.5;

if ( image_angle != 0 ) or ( image_xscale != 1 ) or ( image_yscale != 1 ) {
    
    //If this instance has been rotated or stretched in the room editor, add every side as a shadow caster
    //Use clockwise definitions!
    lighting_caster_add_geometry( _l, _t,   _r, _t ); //Top
    lighting_caster_add_geometry( _r, _t,   _r, _b ); //Right
    lighting_caster_add_geometry( _r, _b,   _l, _b ); //Bottom
    lighting_caster_add_geometry( _l, _b,   _l, _t ); //Left
    
} else {
    
    //If this instance is axis-aligned and non-stretched, only add shadow casting sides if they're external
    //Use clockwise definitions!
    if ( !position_meeting( x, y - 32, obj_static_block ) ) lighting_caster_add_geometry( _l, _t,   _r, _t ); //Top
    if ( !position_meeting( x + 32, y, obj_static_block ) ) lighting_caster_add_geometry( _r, _t,   _r, _b ); //Right
    if ( !position_meeting( x, y + 32, obj_static_block ) ) lighting_caster_add_geometry( _r, _b,   _l, _b ); //Bottom
    if ( !position_meeting( x - 32, y, obj_static_block ) ) lighting_caster_add_geometry( _l, _b,   _l, _t ); //Left
    
}