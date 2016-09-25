///scr_lighting_start( ambient colour, self-lighting, bump size )
//
//  Initialises the necessary variables for a controller object to use the lighting system.
//  Should be called in one object per room.
//  Must be called before scr_lighting_build(), scr_lighting_draw(), and scr_lighting_end().
//
//  argument0: The ambient colour. Defaults to black. [Optional]
//  argument1: Whether or not to use self-lighting.   [Optional]
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
//  https://creativecommons.org/licenses/by-nc-sa/4.0/

//Assign the ambient colour used for the darkest areas of the screen. This can be changed on the fly.
if ( argument_count >= 1 ) {
    if ( argument[0] != noone ) lightingAmbientColour = argument[0] else lightingAmbientColour = c_black;
} else lightingAmbientColour = c_black;

//If culling is switched on, shadows will only be cast from the rear faces of shadow casters.
//This requires careful object placement as not to create weird graphical glitches.
if ( argument_count >= 2 ) {
    if ( argument[1] != noone ) lightingSelfLighting = argument[1] else lightingSelfLighting = false;
} else lightingSelfLighting = false;

//
if ( argument_count >= 3 ) {
    if ( argument[2] != noone ) lightingBumpSize = argument[2] else lightingBumpSize = 0.005;
} else lightingBumpSize = 0.02;

//--- Create vertex format for the shadow casting vertex buffers
vertex_format_begin();
vertex_format_add_position_3d();
vft_shadowGeometry = vertex_format_end();

//--- Initialise variables used and updated in scr_lighting_build()
srf_bump = noone; //Screen-space surface for composite bump maps
vbf_staticShadows = noone; //Vertex buffer describing the shadow casting geometry of the static objects.
vbf_dynamicShadows = noone; //As above but for dynamic shadow casters. This is updated every step.
srf_lighting = noone; //Screen-space surface for final compositing of individual surfaces.
