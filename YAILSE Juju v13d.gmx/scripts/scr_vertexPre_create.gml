///scr_vertexPre_create( object, sprite, image  )

var obj = argument0;
var spr = argument1;
var img = argument2;

if ( instance_number( obj ) > 0 ) {
    
    var vbuff = vertex_create_buffer();
    vertex_begin( vbuff, vft_vertexPre );
    
    with( obj ) {
        
        var uvs = sprite_get_uvs( spr, img );
        
        d3d_transform_set_translation( -sprite_get_xoffset( spr ), -sprite_get_yoffset( spr ), 0 );
        d3d_transform_add_scaling( image_xscale, image_yscale, 1 );
        d3d_transform_add_rotation_z( image_angle );
        d3d_transform_add_translation( x, y, 0 );
            var LT = d3d_transform_vertex(                       0,                        0, 0 );
            var RT = d3d_transform_vertex( sprite_get_width( spr ),                        0, 0 );
            var LB = d3d_transform_vertex(                       0, sprite_get_height( spr ), 0 );
            var RB = d3d_transform_vertex( sprite_get_width( spr ), sprite_get_height( spr ), 0 );
        d3d_transform_set_identity();
        
        vertex_position( vbuff,   LT[0], LT[1] ); vertex_texcoord( vbuff,   uvs[0], uvs[1] );
        vertex_position( vbuff,   RT[0], RT[1] ); vertex_texcoord( vbuff,   uvs[2], uvs[1] );
        vertex_position( vbuff,   LB[0], LB[1] ); vertex_texcoord( vbuff,   uvs[0], uvs[3] );
        
        vertex_position( vbuff,   RT[0], RT[1] ); vertex_texcoord( vbuff,   uvs[2], uvs[1] );
        vertex_position( vbuff,   LB[0], LB[1] ); vertex_texcoord( vbuff,   uvs[0], uvs[3] );
        vertex_position( vbuff,   RB[0], RB[1] ); vertex_texcoord( vbuff,   uvs[2], uvs[3] );
        
    }
    
    vertex_end( vbuff );
    vertex_freeze( vbuff );
    
    return vbuff;

} else return noone;
