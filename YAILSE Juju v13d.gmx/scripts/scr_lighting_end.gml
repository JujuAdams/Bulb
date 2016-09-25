///scr_lighting_end()
//
//  Free memory used by the lighting system.
//  Don't forget to call this!
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

//This line causes bugs for some reason...
//vertex_format_delete( vft_shadowGeometry );
if ( vbf_staticShadows != noone ) vertex_delete_buffer( vbf_staticShadows );
if ( vbf_dynamicShadows != noone ) vertex_delete_buffer( vbf_dynamicShadows );
if ( srf_lighting != noone ) surface_free( srf_lighting );
