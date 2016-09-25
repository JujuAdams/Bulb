///scr_lighting_draw()
//
//  Separate drawing call for the lighting surface.
//  Should be called in one object per room, the same object that called scr_lighting_build().
//  This script can only be called AFTER scr_lighting_build().
//  
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

draw_set_blend_mode_ext( bm_dest_color, bm_zero );
draw_surface( srf_lighting, view_xview[LIGHTING_VIEW], view_yview[LIGHTING_VIEW] );
draw_set_blend_mode( bm_normal );
