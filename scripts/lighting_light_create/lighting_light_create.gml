/// @param deferred
//
//  Initialises the necessary variables for a light object to use the lighting system.
//  Must be called before lighting_light_destroy().
//  
//  return: Nothing.
//  
//  March 2019
//  @jujuadams
//  Based on the YAILSE system by xot (John Leffingwell) of gmlscripts.com
//  
//  This code and engine are provided under the Creative Commons "Attribution - NonCommerical - ShareAlike" international license.
//  https://creativecommons.org/licenses/by-nc-sa/4.0/

light_w         = sprite_get_width(  sprite_index );
light_h         = sprite_get_height( sprite_index );
light_w_half    = 0.5*light_w;
light_h_half    = 0.5*light_h;
light_on_screen = true;

if ( LIGHTING_ENABLE_DEFERRED && argument0 ) {
    light_deferred = true;
    srf_light = surface_create( light_w, light_h );
} else {
    light_deferred = false;
    srf_light = -1;
}