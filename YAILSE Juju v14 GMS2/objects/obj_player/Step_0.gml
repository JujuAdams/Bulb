///Step

//--- Input handling...
var _x = 0;
var _y = 0;

if ( keyboard_check( vk_up    ) ) or ( keyboard_check( ord( "W" ) ) ) _y -= 5;
if ( keyboard_check( vk_down  ) ) or ( keyboard_check( ord( "S" ) ) ) _y += 5;
if ( keyboard_check( vk_left  ) ) or ( keyboard_check( ord( "A" ) ) ) _x -= 5;
if ( keyboard_check( vk_right ) ) or ( keyboard_check( ord( "D" ) ) ) _x += 5;

repeat( abs( _x ) ) if ( !place_meeting( x + sign( _x ), y, obj_par_block ) ) x += sign( _x ) else break;
repeat( abs( _y ) ) if ( !place_meeting( x, y + sign( _y ), obj_par_block ) ) y += sign( _y ) else break;

//--- Misc. controls
if ( keyboard_check_pressed( vk_escape ) ) game_end();
if ( keyboard_check_pressed( vk_f1 ) ) show_debug = !show_debug;

if ( show_debug ) {
    if ( keyboard_check_pressed( ord( "1" ) ) ) with( obj_light_discoooo ) visible = !visible;
    if ( keyboard_check_pressed( ord( "2" ) ) ) lighting_self_lighting = !lighting_self_lighting;
}

//--- Shooting
//Note the use of an alarm to control the rate of fire.
if ( mouse_check_button( mb_left ) ) and ( alarm[0] < 0 ) {
    
    alarm[0] = 6;
    
    var _inst = instance_create_depth( x, y, 0, obj_light_plasma );
    _inst.speed = 10;
    _inst.direction = point_direction( x, y, mouse_x, mouse_y ) + random_range( -5, 5 );
    
}

__view_set( e__VW.XView, LIGHTING_VIEW, round( x - __view_get( e__VW.WView, LIGHTING_VIEW ) * 0.5 ) );
__view_set( e__VW.YView, LIGHTING_VIEW, round( y - __view_get( e__VW.HView, LIGHTING_VIEW ) * 0.5 ) );