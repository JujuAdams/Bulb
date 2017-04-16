///Create

//Whether or not to show debug text
show_debug = false;

//Create a camera
view_enabled = true;
view_set_visible( 0, true );
camera = camera_create_view( x - 640, y - 360,   1280, 720, 0,   noone, 0, 0, 0, 0 );
view_set_camera( 0, camera );

//Set up a vertex buffer for drawing the diffuse base texture for the walls
vertexpre_start();
vbf_static_block = vertexpre_create( obj_static_block, spr_static_block, 0 );

//Start the lighting system
lighting_create( camera, make_colour_rgb( 50, 50, 80 ), false );