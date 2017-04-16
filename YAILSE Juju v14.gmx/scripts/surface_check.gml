///surface_check( surface, width, height )
//
//  Simple utility to check a surface and replace it if necessary.
//  
//  April 2017
//  @jujuadams
//  /u/jujuadam
//  Juju on the GMC

if ( !surface_exists( argument0 ) ) return surface_create( argument1, argument2 ) else return argument0;
