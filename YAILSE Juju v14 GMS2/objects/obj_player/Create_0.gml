///Create

//Whether or not to show debug text
show_debug = false;
smoothed_frame_time = 1;
alarm_set( 1, 30 );

//Create a camera
view_enabled = true;
view_set_visible( 0, true );
camera = camera_create_view( x - 640, y - 360,   1280, 720, 0,   noone, 0, 0, 0, 0 );
view_set_camera( 0, camera );

//Set up a vertex buffer for drawing the diffuse base texture for the walls
vertexpre_start();
vbf_static_block = vertexpre_create( obj_static_occluder, spr_static_block, 0 );

//Start the lighting system
lighting_create( camera, make_colour_rgb( 50, 50, 80 ), false );

instance_create_layer( x, y, layer, obj_light_torch );





vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_colour();
vft_simple = vertex_format_end();

vbf_test = vertex_create_buffer();
var _vbuff = vbf_test;
vertex_begin( _vbuff, vft_simple );

vertex_position_3d( _vbuff,   0,   0, 0 ); vertex_colour( _vbuff, c_black, 0 );
vertex_position_3d( _vbuff, 100,   0, 0 ); vertex_colour( _vbuff, c_black, 0 );
vertex_position_3d( _vbuff,   0, 100, 0 ); vertex_colour( _vbuff, c_black, 0 );
vertex_position_3d( _vbuff,  50,   0, 1 ); vertex_colour( _vbuff, c_red, 1 );
vertex_position_3d( _vbuff, 150, 100, 1 ); vertex_colour( _vbuff, c_red, 1 );
vertex_position_3d( _vbuff,  50, 100, 1 ); vertex_colour( _vbuff, c_red, 1 );

vertex_end( _vbuff );
