//  Initialises the necessary variables for a light object to use the lighting system.
//  Must be called before scr_lighting_light_step() and scr_lighting_light_destroy().
//
//  argument0: The maximum x-scaling that is to be expected. [Optional]
//  argument1: The maximum y-scaling that is to be expected. [Optional]
//  return: Nothing.
//  
//  April 2017
//  @jujuadams
//  /u/jujuadam
//  Juju on the GMC
//
//  Based on the YAILSE system by xot (John Leffingwell) of gmlscripts.com
//  
//  This code and engine are provided under the Creative Commons "Attribution - NonCommerical - ShareAlike" international license.

light_w =  sprite_get_width( sprite_index );
light_h = sprite_get_height( sprite_index );
light_w_half = 0.5*light_w;
light_h_half = 0.5*light_h;

if ( !LIGHTING_NEVER_DEFERRED ) srf_light = surface_create( light_w, light_h );
on_screen = true;