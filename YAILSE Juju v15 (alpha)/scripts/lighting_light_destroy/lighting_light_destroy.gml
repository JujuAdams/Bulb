//  Free memory taken up by the light. Should be called in the Room End event and the Destroy event.
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

if ( !LIGHTING_NEVER_DEFERRED ) surface_free( srf_light );