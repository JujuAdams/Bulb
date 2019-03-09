//Player input
var _x = 0;
var _y = 0;

if ( keyboard_check( vk_up    ) ) or ( keyboard_check( ord( "W" ) ) ) y -= 5;
if ( keyboard_check( vk_down  ) ) or ( keyboard_check( ord( "S" ) ) ) y += 5;
if ( keyboard_check( vk_left  ) ) or ( keyboard_check( ord( "A" ) ) ) x -= 5;
if ( keyboard_check( vk_right ) ) or ( keyboard_check( ord( "D" ) ) ) x += 5;

//Other controls
if ( keyboard_check_pressed( vk_escape  ) ) game_end();
if ( keyboard_check_pressed( vk_f1      ) ) {
	show_debug = !show_debug;
	show_debug_overlay( show_debug );
}

if ( keyboard_check_pressed( ord( "L" ) ) ) instance_create_depth( x, y, 0, obj_light_discoooo );
if ( keyboard_check( ord( "T" ) ) ) and ( fps_real > 61 ) instance_create_depth( x, y, 0, obj_light_discoooo );
if ( keyboard_check_pressed( ord( "1" ) ) ) with( obj_light_discoooo ) visible = !visible;
if ( keyboard_check_pressed( ord( "2" ) ) ) lighting_culling = ( lighting_culling == cull_noculling ) ? cull_counterclockwise : cull_noculling;
if ( keyboard_check_pressed( ord( "3" ) ) ) {
    allow_deferred = !allow_deferred;
    if ( allow_deferred ) {
        with( obj_par_light ) light_deferred = demo_is_deferred;
    } else {
        with( obj_par_light ) light_deferred = false;
    }
}

//Shooting
if ( mouse_check_button( mb_left ) ) and ( alarm_get( 0 ) <= 0 ) {
    
    alarm_set( 0, 12 );
    
    var _inst = instance_create_depth( x, y, 0, obj_light_plasma );
	with( _inst ) {
		speed = 10;
		direction = point_direction( x, y, mouse_x, mouse_y ) + random_range( -5, 5 );
		image_angle = direction;
	}
    
}

//Update camera position
camera_set_view_pos( camera, round( x - 0.5*camera_get_view_width( camera ) ), round( y - 0.5*camera_get_view_height( camera ) ) );

//Update debug timers
if ( alarm_get(1) < 0 )
{
    smoothed_frame_time = lerp( smoothed_frame_time, 1000/fps_real, 0.005 );
    smoothed_fps = lerp( smoothed_fps, fps_real, 0.005 );
}