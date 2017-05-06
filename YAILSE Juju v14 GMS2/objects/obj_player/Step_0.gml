///Step

//Player input
var _x = 0;
var _y = 0;

if ( keyboard_check( vk_up    ) ) or ( keyboard_check( ord( "W" ) ) ) _y -= 5;
if ( keyboard_check( vk_down  ) ) or ( keyboard_check( ord( "S" ) ) ) _y += 5;
if ( keyboard_check( vk_left  ) ) or ( keyboard_check( ord( "A" ) ) ) _x -= 5;
if ( keyboard_check( vk_right ) ) or ( keyboard_check( ord( "D" ) ) ) _x += 5;

x += _x;
y += _y;

/*
repeat( abs( _x ) ) if ( !place_meeting( x + sign( _x ), y, obj_par_occluder ) ) x += sign( _x ) else break;
repeat( abs( _y ) ) if ( !place_meeting( x, y + sign( _y ), obj_par_occluder ) ) y += sign( _y ) else break;
*/

//Other controls
if ( keyboard_check_pressed( vk_escape  ) ) game_end();
if ( keyboard_check_pressed( vk_f1      ) ) show_debug = !show_debug;
if ( keyboard_check_pressed( ord( "L" ) ) ) instance_create_depth( x, y, 0, obj_light_discoooo );
if ( keyboard_check_pressed( ord( "1" ) ) ) with( obj_light_discoooo ) visible = !visible;
if ( keyboard_check_pressed( ord( "2" ) ) ) lighting_culling = ( lighting_culling == cull_noculling ) ? cull_counterclockwise : cull_noculling;

//Shooting
if ( mouse_check_button( mb_left ) ) and ( alarm_get( 0 ) <= 0 ) {
    
    alarm_set( 0, 3 );
    
    var _inst = instance_create_depth( x, y, 0, obj_light_plasma );
    _inst.speed = 10;
    _inst.direction = point_direction( x, y, mouse_x, mouse_y ) + random_range( -5, 5 );
    
}

//Update camera position
camera_set_view_pos( camera, round( x - 0.5*camera_get_view_width( camera ) ), round( y - 0.5*camera_get_view_height( camera ) ) );

if ( alarm_get( 1 ) <= 0 ) smoothed_frame_time = lerp( smoothed_frame_time, 1000/fps_real, 0.01 );