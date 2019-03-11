/// @param ambient_colour
/// @param self_lighting
/// @param culling
//
//  Initialises the necessary variables for a controller object to use the lighting system.
//  Should be called in one object per room.
//  Must be called before lighting_build(), lighting_draw(), and lighting_end().
//
//  argument0: The ambient colour. Defaults to black. [Optional]
//  argument1: Whether or not to use self-lighting.   [Optional]
//  return: Nothing.
//  
//  March 2019
//  @jujuadams
//  Based on the YAILSE system by xot (John Leffingwell) of gmlscripts.com
//  
//  This code and engine are provided under the Creative Commons "Attribution - NonCommerical - ShareAlike" international license.
//  https://creativecommons.org/licenses/by-nc-sa/4.0/

#macro ON_DIRECTX ((os_type == os_windows) || (os_type == os_xboxone) || (os_type == os_uwp) || (os_type == os_winphone) || (os_type == os_win8native))

#macro LIGHTING_ZFAR                              1
#macro LIGHTING_DYNAMIC_BORDER                  256
#macro LIGHTING_REUSE_DYNAMIC_BUFFER           true
#macro LIGHTING_CACHE_DYNAMIC_OCCLUDERS       false
#macro LIGHTING_ENABLE_DEFERRED                true
#macro LIGHTING_FLIP_CAMERA_Y            ON_DIRECTX

enum E_LIGHTING_MODE
{
    HARD_BM_ADD, //Basic hard shadows with z-buffer stenciling, using the typical bm_add blend mode
    HARD_BM_MAX, //As above, but using bm_max
    SOFT_BM_ADD
}


//Assign the camera used to draw the lights
lighting_camera = argument0;

//Assign the ambient colour used for the darkest areas of the screen. This can be changed on the fly.
lighting_ambient_colour = argument1;

//If culling is switched on, shadows will only be cast from the rear faces of occluders.
//This requires careful object placement as not to create weird graphical glitches.
lighting_culling = argument2 ? cull_counterclockwise : cull_noculling;

lighting_mode = E_LIGHTING_MODE.SOFT_BM_ADD;




//Create a standard vertex format
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_colour();
vft_3d_colour = vertex_format_end();

//Create a standard vertex format
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_texcoord();
vft_3d_texture = vertex_format_end();



//Initialise variables used and updated in lighting_build()
vbf_static_shadows  = noone; //Vertex buffer describing the geometry of static occluder objects.
vbf_dynamic_shadows = noone; //As above but for dynamic shadow occluders. This is updated every step.
vbf_wipe            = noone; //This vertex buffer is used to reset the z-buffer during compositing.
srf_lighting        = noone; //Screen-space surface for final compositing of individual surfaces.