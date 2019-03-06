/// @param surface
/// @param width
/// @param height
//
//  Simple utility to check a surface and replace it if necessary.
//  
//  May 2017
//  @jujuadams
//  /u/jujuadam
//  Juju on the GMC
//  
//  This code and engine are provided under the Creative Commons "Attribution - NonCommerical - ShareAlike" international license.
//  https://creativecommons.org/licenses/by-nc-sa/4.0/

if ( !surface_exists( argument0 ) ) return surface_create( argument1, argument2 ) else return argument0;