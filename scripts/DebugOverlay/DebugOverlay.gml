function DebugOverlay()
{
    var _tonemapName = "???";
    switch(renderer.GetTonemap())
    {
        case BULB_TONEMAP_BAD_GAMMA:         _tonemapName = "\"Bad Gamma!\""             break;
        case BULB_TONEMAP_NONE:              _tonemapName = "\"None\""                   break;
        case BULB_TONEMAP_CLAMP:             _tonemapName = "\"Clamp\""                  break;
        case BULB_TONEMAP_REINHARD:          _tonemapName = "\"Reinhard\"";              break;
        case BULB_TONEMAP_REINHARD_EXTENDED: _tonemapName = "\"Reinhard Extended\"";     break;
        case BULB_TONEMAP_UNCHARTED2:        _tonemapName = "\"Uncharted 2\"";           break;
        case BULB_TONEMAP_ACES:              _tonemapName = "\"ACES\"";                  break;
        case BULB_TONEMAP_UNREAL3:           _tonemapName = "\"Unreal 3\"";              break;
        case BULB_TONEMAP_HBD:               _tonemapName = "\"Heji & Burgess-Dawson\""; break;
    }
    
    draw_set_color(c_white);
    shader_set(shdPremultiplyAlpha);
    gpu_set_blendenable(false);
    
    //If we're showing help text...
    if (showDebug)
    {
        draw_set_halign(fa_center);
        draw_text(display_get_gui_width()*0.5, 25, "FPS = " + string_format(fps_real, 4, 0) + "," + string_format(smoothedFrameTime, 2, 2) + "ms");
        
        draw_set_halign(fa_left);
        var _str = "lights = " + string(array_length(renderer.__lightsArray));
        _str += "\nstatic occluders = " + string(array_length(renderer.__staticOccludersArray));
        _str += "\ndynamic occluders = " + string(array_length(renderer.__dynamicOccludersArray)) + "\n";
        
        _str += "\nsoft = " + (renderer.soft? "true" : "false");
        _str += "\nself-renderer = " + (renderer.selfLighting? "true" : "false");
        _str += "\ntonemap = " + _tonemapName;
        _str += "\nHDR = " + ((renderer.hdr && BULB_HDR_AVAILABLE)? "true" : "false");
        
        draw_text(5, 25, _str);
        
        draw_set_valign(fa_bottom);
        var _str = "1: Toggle lights";
        _str += "\n2: Toggle soft shadow mode";
        _str += "\n3: Toggle self-renderer";
        if (BULB_HDR_AVAILABLE) _str += "\n4: Toggle HDR";
        _str += "\n5: Change tonemapping";
        _str += "\n6: Toggle normal map";
        _str += "\nL: Create new disco light";
        _str += "\nArrows/WASD: Move";
        _str += "\nLeft click: Fire plasma";
        _str += "\nRight click: Toggle torch";
        draw_text(5, display_get_gui_height() - 5, _str);
    }
    else
    {
        var _mode = (renderer.soft? "soft" : "hard")
                  + (renderer.selfLighting? ", self-lighting" : "")
                  + ", tonemap=" + _tonemapName
                  + ((renderer.hdr && BULB_HDR_AVAILABLE)? ", HDR" : "");
        
        draw_set_halign(fa_center);
        draw_text(display_get_gui_width()*0.5, 5, _mode + " // " + "FPS = " + string_format(fps, 2, 0));
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_bottom);
        var _str = "Press F1 to view debug and controls";
        draw_text(5, display_get_gui_height() - 5, _str);
    }
    
    //Always credit properly :)
    draw_set_halign(fa_right);
    var _str = "v" + BULB_VERSION + "   " + BULB_DATE;
    _str += "\nJuju Adams";
    _str += "\nAfter work by xot / John Leffingwell";
    _str += "\nThanks to @Mordwaith and Alexey Mihailov (@LexPest)";
    draw_text(display_get_gui_width() - 5, display_get_gui_height() - 5, _str);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    gpu_set_blendmode(bm_normal);
    gpu_set_blendenable(true);
    shader_reset();
}