//  Cleans up any allocated data structures/surfaces that a light has created.
//  Must be called after lighting_light_create().
//  
//  return: Nothing.
//  
//  March 2019
//  @jujuadams
//  Based on the YAILSE system by xot (John Leffingwell) of gmlscripts.com
//  
//  This code and engine are provided under the Creative Commons "Attribution - NonCommerical - ShareAlike" international license.
//  https://creativecommons.org/licenses/by-nc-sa/4.0/

if ( LIGHTING_ENABLE_DEFERRED && surface_exists( srf_light ) ) surface_free( srf_light );