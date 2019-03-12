//Create a camera
view_enabled = true;
view_set_visible( 0, true );
camera = camera_create_view( x - 640, y - 360,   1280, 720, 0,   noone, 0, 0, 0, 0 );
view_set_camera( 0, camera );

//Start the lighting system
lighting_create( camera, make_colour_rgb( 50, 50, 80 ), false, E_LIGHTING_MODE.HARD_BM_ADD, true );

//Create a light attached to the player
instance_create_layer( x, y, layer, obj_light_torch );




//Set up a vertex buffer for drawing the diffuse base texture for the walls
//This isn't strictly part of the lighting example
vertexpre_start();
vbf_static_block = vertexpre_create( obj_static_occluder, spr_static_block, 0 );

//Some debug values
allow_deferred = false;
show_debug = false;
draw_end_time = 300;
smoothed_draw_end_time = 300;
smoothed_frame_time = 1;
smoothed_fps = 1000;
alarm_set( 1, 30 );