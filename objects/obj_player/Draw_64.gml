draw_set_color( c_white );

//If we're showing help text...
if ( show_debug ) {
    
    var _visible_lights = 0;
    with( obj_par_light ) if ( light_on_screen ) _visible_lights++;
    var _visible_dynamics = 0;
    with( obj_dynamic_occluder ) if ( light_on_screen ) _visible_dynamics++;
    
    draw_set_halign( fa_center );
    draw_text( display_get_gui_width()*0.5, 25, "smoothed frame time = " + string_format( smoothed_frame_time, 2, 2 ) + "ms\nFPS = " + string_format( smoothed_fps, 4, 0 ) + " (" + string_format( fps_real, 4, 0 ) + ")" );
    
    draw_set_halign( fa_left );
    var _str = "dynamic lights = " + string( _visible_lights ) + " (total=" + string( instance_number( obj_par_light ) ) + ")";
    _str += "\nstatic occluders = " + string( instance_number( obj_static_occluder ) );
    _str += "\ndynamic occluders = " + string( _visible_dynamics ) + " (total=" + string( instance_number( obj_dynamic_occluder ) ) + ")";
    
    switch( lighting_mode )
    {
        case E_LIGHTING_MODE.HARD_BM_ADD: _str += "\nrender mode = Z-clip, bm_add"; break
        case E_LIGHTING_MODE.HARD_BM_MAX: _str += "\nrender mode = Z-clip, bm_max"; break;
        case E_LIGHTING_MODE.SOFT_BM_ADD: _str += "\nrender mode = Alpha-clip, bm_add"; break;
    }
    
    if ( lighting_partial_clear ) _str += "\nPartial clear enabled";
    
    draw_text( 5, 25, _str );
    
    draw_set_valign( fa_bottom );
    var _str = "1: Toggle lights";
    _str += "\n2: Toggle self-lighting";
    _str += "\n3: Change render mode";
    _str += "\nL: Create new disco light";
    _str += "\nArrows/WASD: Move";
    _str += "\nLeft click: Fire plasma";
    _str += "\nRight click: Toggle torch";
    draw_text( 5, display_get_gui_height() - 5, _str );

} else {
    
    switch( lighting_mode )
    {
        case E_LIGHTING_MODE.HARD_BM_ADD: var _mode = "Z-clip, bm_add"; break
        case E_LIGHTING_MODE.HARD_BM_MAX: var _mode = "Z-clip, bm_max"; break;
        case E_LIGHTING_MODE.SOFT_BM_ADD: var _mode = "Alpha-clip, bm_add"; break;
    }
    
    draw_set_color( c_white );
    draw_set_halign( fa_center );
    draw_text( display_get_gui_width()*0.5, 5, "FPS = " + string_format( fps, 2, 0 ) + " / " + _mode + " = " + string_format( smoothed_draw_end_time, 4, 0 ) + "us" );
    
    draw_set_halign( fa_left );
    draw_set_valign( fa_bottom );
    var _str = "Press F1 to view debug and controls";
    draw_text( 5, display_get_gui_height() - 5, _str );
    
}

//Always credit properly :)
draw_set_halign( fa_right );
var _str = "v17.0.0 WIP   March 2019";
_str += "\nJuju Adams - @jujuadams";
_str += "\nAfter work by xot / John Leffingwell";
_str += "\nThanks to @Mordwaith and Alexey Mihailov (@LexPest)";
draw_text( display_get_gui_width() - 5, display_get_gui_height() - 5, _str );

draw_set_halign( fa_left );
draw_set_valign( fa_top );