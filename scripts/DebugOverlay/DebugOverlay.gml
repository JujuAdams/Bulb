function DebugOverlay()
{
    draw_set_color(c_white);
    shader_set(shdPremultiplyAlpha);
    gpu_set_blendenable(false);
    
    //If we're showing help text...
    if (showDebug)
    {
        draw_set_halign(fa_center);
        draw_text(display_get_gui_width()*0.5, 25, "FPS = " + string_format(fps_real, 4, 0) + "," + string_format(smoothedFrameTime, 2, 2) + "ms / .Draw() = " + string_format(smoothedDrawEndTime, 4, 0) + "us");
        
        draw_set_halign(fa_left);
        var _str = "lights = " + string(array_length(lighting.__lightsArray));
        _str += "\nstatic occluders = " + string(array_length(lighting.__staticOccludersArray));
        _str += "\ndynamic occluders = " + string(array_length(lighting.__dynamicOccludersArray)) + "\n";
        
        _str += "\nsoft = " + (lighting.soft? "true" : "false");
        _str += "\nself-lighting = " + (lighting.selfLighting? "true" : "false");
        _str += "\nHDR = " + (lighting.hdr? "true" : "false");
        
        draw_text(5, 25, _str);
        
        draw_set_valign(fa_bottom);
        var _str = "1: Toggle lights";
        _str += "\n2: Toggle soft shadow mode";
        _str += "\n3: Toggle self-lighting";
        _str += "\n4: Toggle HDR";
        _str += "\nL: Create new disco light";
        _str += "\nArrows/WASD: Move";
        _str += "\nLeft click: Fire plasma";
        _str += "\nRight click: Toggle torch";
        draw_text(5, display_get_gui_height() - 5, _str);
    }
    else
    {
        var _mode = (lighting.soft? "soft shadows" : "hard shadows") + (lighting.selfLighting? ", self-lighting" : "") + (lighting.hdr? ", HDR" : "");
        
        draw_set_halign(fa_center);
        draw_text(display_get_gui_width()*0.5, 5, "FPS = " + string_format(fps, 2, 0) + " / " + _mode + " = " + string_format(smoothedDrawEndTime, 4, 0) + "us");
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_bottom);
        var _str = "Press F1 to view debug and controls";
        draw_text(5, display_get_gui_height() - 5, _str);
    }
    
    //Always credit properly :)
    draw_set_halign(fa_right);
    var _str = "v" + __BULB_VERSION + "   " + __BULB_DATE;
    _str += "\nJuju Adams - @jujuadams";
    _str += "\nAfter work by xot / John Leffingwell";
    _str += "\nThanks to @Mordwaith and Alexey Mihailov (@LexPest)";
    draw_text(display_get_gui_width() - 5, display_get_gui_height() - 5, _str);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    gpu_set_blendmode(bm_normal);
    gpu_set_blendenable(true);
    shader_reset();
}