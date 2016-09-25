///scr_lighting_light_create( max xscale, max yscale )
//
//  Initialises the necessary variables for a light object to use the lighting system.
//  Must be called before scr_lighting_light_step() and scr_lighting_light_destroy().
//
//  argument0: The maximum x-scaling that is to be expected. [Optional]
//  argument1: The maximum y-scaling that is to be expected. [Optional]
//  return: Nothing.
//  
//  November 2015
//  @jujuadams
//  /u/jujuadam
//  Juju on the GMC
//
//  Based on the YAILSE system by xot (John Leffingwell) of gmlscripts.com
//  
//  This code and engine are provided under the Creative Commons "Attribution - NonCommerical - ShareAlike" international license.

if ( argument_count >= 1 ) lightMaxXScale = argument[0] else lightMaxXScale = image_xscale;
if ( argument_count >= 2 ) lightMaxYScale = argument[1] else lightMaxYScale = image_yscale;

lightW =  sprite_get_width( sprite_index ) * lightMaxXScale;
lightH = sprite_get_height( sprite_index ) * lightMaxYScale;
lightWHalf = lightW * 0.5;
lightHHalf = lightH * 0.5;

srf_light = surface_create( lightW, lightH );
onScreen = false;
