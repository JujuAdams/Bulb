///lighting_light_step()
//
//  Updates the light - specifically, whether it intersects the main viewport.
//  
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


if ( rectangle_in_rectangle( x - light_w_half, y - light_h_half,
                             x + light_w_half, y + light_h_half,
                             __view_get( e__VW.XView, LIGHTING_VIEW ), __view_get( e__VW.YView, LIGHTING_VIEW ),
                             __view_get( e__VW.XView, LIGHTING_VIEW ) + __view_get( e__VW.WView, LIGHTING_VIEW ), __view_get( e__VW.YView, LIGHTING_VIEW ) + __view_get( e__VW.HView, LIGHTING_VIEW ) ) ) and ( visible ) {
    on_screen = true;
} else {
    on_screen = false;
}
