///vertexpre_create( object, sprite, image )
//  
//  April 2017
//  @jujuadams
//  /u/jujuadam
//  Juju on the GMC
//  
//  This code and engine are provided under the Creative Commons "Attribution - NonCommerical - ShareAlike" international license.

var _obj = argument0;
var _spr = argument1;
var _img = argument2;

if ( instance_number( _obj ) > 0 ) {
    
    var _vbuff = vertex_create_buffer();
    vertex_begin( _vbuff, vft_vertexpre );
    
    with( _obj ) {
        
        var _uvs = sprite_get_uvs( _spr, _img );
        
        d3d_transform_set_translation( -sprite_get_xoffset( _spr ), -sprite_get_yoffset( _spr ), 0 );
        d3d_transform_add_scaling( image_xscale, image_yscale, 1 );
        d3d_transform_add_rotation_z( image_angle );
        d3d_transform_add_translation( x, y, 0 );
            var _lt = d3d_transform_vertex(                        0,                         0, 0 );
            var _rt = d3d_transform_vertex( sprite_get_width( _spr ),                         0, 0 );
            var _lb = d3d_transform_vertex(                        0, sprite_get_height( _spr ), 0 );
            var _rb = d3d_transform_vertex( sprite_get_width( _spr ), sprite_get_height( _spr ), 0 );
        d3d_transform_set_identity();
        
        vertex_position( _vbuff,   _lt[0], _lt[1] ); vertex_texcoord( _vbuff,   _uvs[0], _uvs[1] );
        vertex_position( _vbuff,   _rt[0], _rt[1] ); vertex_texcoord( _vbuff,   _uvs[2], _uvs[1] );
        vertex_position( _vbuff,   _lb[0], _lb[1] ); vertex_texcoord( _vbuff,   _uvs[0], _uvs[3] );
        
        vertex_position( _vbuff,   _rt[0], _rt[1] ); vertex_texcoord( _vbuff,   _uvs[2], _uvs[1] );
        vertex_position( _vbuff,   _lb[0], _lb[1] ); vertex_texcoord( _vbuff,   _uvs[0], _uvs[3] );
        vertex_position( _vbuff,   _rb[0], _rb[1] ); vertex_texcoord( _vbuff,   _uvs[2], _uvs[3] );
        
    }
    
    vertex_end( _vbuff );
    vertex_freeze( _vbuff );
    
    return _vbuff;

} else return noone;
