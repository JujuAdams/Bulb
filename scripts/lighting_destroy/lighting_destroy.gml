//  Free memory used by the lighting system.
//  Don't forget to call this!
//  
//  return: Nothing.
//  
//  March 2019
//  @jujuadams
//  Based on the YAILSE system by xot (John Leffingwell) of gmlscripts.com
//
//  Based on the YAILSE system by xot (John Leffingwell) of gmlscripts.com
//  
//  This code and engine are provided under the Creative Commons "Attribution - NonCommerical - ShareAlike" international license.
//  https://creativecommons.org/licenses/by-nc-sa/4.0/

vertex_format_delete( vft_3d_colour );
if ( vbf_static_shadows  != noone ) vertex_delete_buffer( vbf_static_shadows );
if ( vbf_dynamic_shadows != noone ) vertex_delete_buffer( vbf_dynamic_shadows );
if ( vbf_zbuffer_reset   != noone ) vertex_delete_buffer( vbf_zbuffer_reset );
if ( surface_exists( srf_lighting ) ) surface_free( srf_lighting );
