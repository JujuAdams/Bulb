///lighting_caster_dynamic_step()
//
//  Updates the caster - specifically, whether it intersects the main viewport. Note that the viewport is extended.
//  This is to ensure that lights outside the viewport still cast appropriate shadows even if the shadow casters themselves are outside the viewport.
//  LIGHTING_DYNAMIC_INCLUSIO is typically set to the radius of the largest light in the room.
//
//  return: Nothing
//  
//  April 2017
//  @jujuadams
//  /u/jujuadam
//  Juju on the GMC
//
//  Based on the YAILSE system by xot (John Leffingwell) of gmlscripts.com
//  
//  This code and engine are provided under the Creative Commons "Attribution - NonCommerical - ShareAlike" international license.
//  https://creativecommons.org/licenses/by-nc-sa/4.0/

if ( rectangle_in_rectangle( bbox_left, bbox_top,
                             bbox_right, bbox_left,
                             view_xview[LIGHTING_VIEW] - LIGHTING_DYNAMIC_INCLUSION, view_yview[LIGHTING_VIEW] - LIGHTING_DYNAMIC_INCLUSION,
                             view_xview[LIGHTING_VIEW] + view_wview[LIGHTING_VIEW] + LIGHTING_DYNAMIC_INCLUSION, view_yview[LIGHTING_VIEW] + view_hview[LIGHTING_VIEW] + LIGHTING_DYNAMIC_INCLUSION ) ) {
    on_screen = true;
} else {
    on_screen = false;
}
