/// @param object
/// @param sprite
/// @param image
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
		
		var _matrix = matrix_build( -sprite_get_xoffset( _spr ), -sprite_get_yoffset( _spr ), 0,
		                            0, 0, 0,
									1, 1, 1 );
		_matrix = matrix_multiply( _matrix, matrix_build( 0, 0, 0,
		                                                  0, 0, 0,
												          image_xscale, image_yscale, 1 ) );
		_matrix = matrix_multiply( _matrix, matrix_build( 0, 0, 0,
		                                                  0, 0, image_angle,
												          1, 1, 1 ) );
		_matrix = matrix_multiply( _matrix, matrix_build( x, y, 0,
		                                                  0, 0, 0,
												          1, 1, 1 ) );
		
        _lt = matrix_transform_vertex( _matrix,                        0,                         0, 0 );
		_rt = matrix_transform_vertex( _matrix, sprite_get_width( _spr ),                         0, 0 );
		_lb = matrix_transform_vertex( _matrix,                        0, sprite_get_height( _spr ), 0 );
		_rb = matrix_transform_vertex( _matrix, sprite_get_width( _spr ), sprite_get_height( _spr ), 0 );
		
        vertex_position( _vbuff,   _lt[0], _lt[1] ); vertex_texcoord( _vbuff,   _uvs[0], _uvs[1] ); vertex_colour( _vbuff,   c_white, 1 );
        vertex_position( _vbuff,   _rt[0], _rt[1] ); vertex_texcoord( _vbuff,   _uvs[2], _uvs[1] ); vertex_colour( _vbuff,   c_white, 1 );
        vertex_position( _vbuff,   _lb[0], _lb[1] ); vertex_texcoord( _vbuff,   _uvs[0], _uvs[3] ); vertex_colour( _vbuff,   c_white, 1 );
		
        vertex_position( _vbuff,   _rt[0], _rt[1] ); vertex_texcoord( _vbuff,   _uvs[2], _uvs[1] ); vertex_colour( _vbuff,   c_white, 1 );
        vertex_position( _vbuff,   _rb[0], _rb[1] ); vertex_texcoord( _vbuff,   _uvs[2], _uvs[3] ); vertex_colour( _vbuff,   c_white, 1 );
        vertex_position( _vbuff,   _lb[0], _lb[1] ); vertex_texcoord( _vbuff,   _uvs[0], _uvs[3] ); vertex_colour( _vbuff,   c_white, 1 );
        
    }
	
    vertex_end( _vbuff );
    vertex_freeze( _vbuff );
	
    return _vbuff;

}

return noone;
