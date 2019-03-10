var _camera_l  = camera_get_view_x( lighting_camera );
var _camera_t  = camera_get_view_y( lighting_camera );
var _camera_w  = camera_get_view_width( lighting_camera );
var _camera_h  = camera_get_view_height( lighting_camera );
var _camera_r  = _camera_l + _camera_w;
var _camera_b  = _camera_t + _camera_h;
var _camera_cx = _camera_l + 0.5*_camera_w;
var _camera_cy = _camera_t + 0.5*_camera_h;

var _old_view_matrix = matrix_get( matrix_view );

var _vbuff = vertex_create_buffer();
vertex_begin( _vbuff, vft_3d );
with( obj_static_occluder )
{
    vertexpre_add_points( _vbuff,   bbox_left , bbox_top   ,   bbox_right, bbox_top   ,   0.25,   c_red    );
    vertexpre_add_points( _vbuff,   bbox_right, bbox_top   ,   bbox_right, bbox_bottom,   0.25,   c_lime   );
    vertexpre_add_points( _vbuff,   bbox_right, bbox_bottom,   bbox_left , bbox_bottom,   0.25,   c_blue   );
    vertexpre_add_points( _vbuff,   bbox_left , bbox_bottom,   bbox_left , bbox_top   ,   0.25,   c_yellow );
}
vertex_end( _vbuff );

var _surface = surface_create( _camera_w, _camera_h );

surface_set_target( _surface );
draw_clear_alpha( c_black, 0 );

matrix_set( matrix_view, matrix_build_lookat( _camera_cx, _camera_cy, -16000,
                                              _camera_cx, _camera_cy, 0,
                                              0, 1, 0 ) );
vertex_submit( _vbuff, pr_pointlist, -1 );
//vertex_submit( vbf_static_block, pr_trianglelist, sprite_get_texture( spr_static_block, 0 ) );

gpu_set_ztestenable( true );
gpu_set_zwriteenable( true );
shader_set( shd_1d_pack );
shader_set_uniform_f( shader_get_uniform( shd_1d_pack, "u_vLight" ), _camera_cx, _camera_cy, 500 );
vertex_submit( _vbuff, pr_pointlist, -1 );
shader_reset();
gpu_set_ztestenable( false );
gpu_set_zwriteenable( false );

surface_reset_target();

gpu_set_tex_filter( false );
draw_surface_ext( _surface, _camera_l, _camera_t, 1, 1, 0, c_white, 1 );

shader_set( shd_1d_unpack );
shader_set_uniform_f( shader_get_uniform( shd_1d_unpack, "u_vLight" ), _camera_cx, _camera_cy, 500 );
draw_surface( _surface, _camera_l, _camera_t );
shader_reset();
gpu_set_tex_filter( true );

surface_free( _surface );
vertex_delete_buffer( _vbuff );