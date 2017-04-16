///Draw GUI
//Generic HUD

draw_set_color( c_white );

if ( show_debug ) {
    
    var _visible_lights = 0;
    with( obj_par_light ) if ( on_screen ) _visible_lights++;
    var _visible_dynamics = 0;
    with( obj_dynamic_block ) if ( on_screen ) _visible_dynamics++;
    
    draw_set_halign( fa_center );
    draw_text( window_get_width() * 0.5, 5, string_hash_to_newline("FPS = " + string( fps ) + " / " + string( floor( fps_real) ) ) );
    
    draw_set_halign( fa_left );
    var _str = "dynamic lights = " + string( instance_number( obj_par_light ) ) + " / visible = " + string( _visible_lights );
    _str += "\nstatic casters = " + string( instance_number( obj_static_block ) );
    _str += "\ndynamic casters = " + string( instance_number( obj_dynamic_block ) ) + " / visible = " + string( _visible_dynamics );
    draw_text( 5, 5, _str );
    
    draw_set_valign( fa_bottom );
    var _str = "1: Toggle lights";
    _str += "\n2: Toggle self-lighting";
    _str += "\nArrows/WASD: Move";
    _str += "\nLeft click: Fire plasma";
    draw_text( 5, window_get_height() - 5, _str );

} else {
    
    draw_set_color( c_white );
    draw_set_halign( fa_center );
    draw_text( window_get_width() * 0.5, 5, "FPS = " + string( fps ) );
    
    draw_set_halign( fa_left );
    draw_set_valign( fa_bottom );
    var _str = "Press F1 to view debug";
    _str += "\nArrows/WASD: Move";
    _str += "\nLeft click: Fire plasma";
    draw_text( 5, window_get_height() - 5, _str );
    
}

draw_set_halign( fa_right );
var _str = "April 2017";
_str += "\nJuju Adams - @jujuadams";
_str += "\nAfter work by xot / John Leffingwell";
draw_text( window_get_width() - 5, window_get_height() - 5, _str );

draw_set_halign( fa_left );
draw_set_valign( fa_top );

