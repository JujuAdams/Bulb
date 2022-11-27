#macro __BULB_VERSION              "21.0.0"
#macro __BULB_DATE                 "2022-08-14"
#macro __BULB_ON_DIRECTX           ((os_browser == browser_not_a_browser) && ((os_type == os_windows) || (os_type == os_xboxone) || (os_type == os_uwp) || (os_type == os_winphone) || (os_type == os_win8native)))
#macro __BULB_ZFAR                 16000
#macro __BULB_FLIP_CAMERA_Y        __BULB_ON_DIRECTX
#macro __BULB_PARTIAL_CLEAR        true
#macro __BULB_SQRT_2               1.41421356237
#macro __BULB_NORMAL_CLEAR_COLOUR  #7F7FFF
#macro __BULB_BUILD_TYPE           (BULB_FORCE_PRODUCTION? "exe" : GM_build_type)
#macro __BULB_DISK_CACHE_NAME      ((__BULB_BUILD_TYPE == "run")? "BulbCacheDev.dat" : "BulbCache.dat")

__BulbInitialize();

function __BulbInitialize()
{
    static _initialized = false;
    if (_initialized) return;
    _initialized = true;
    
    __BulbTrace("Welcome to Bulb by @jujuadams! This is version " + __BULB_VERSION + ", " + __BULB_DATE);
    
    //Create a couple vertex formats
    vertex_format_begin();
    vertex_format_add_position_3d();
    vertex_format_add_colour();
    global.__bulbFormat3DColour = vertex_format_end();
    
    //Create a standard vertex format
    vertex_format_begin();
    vertex_format_add_position_3d();
    vertex_format_add_texcoord();
    global.__bulbFormat3DTexture = vertex_format_end();
    
    global.__bulbSpriteDict  = {};
    global.__bulbTilesetDict = {};
    
    global.__bulbProjectDirectory = undefined;
    global.__bulbCacheBuffer      = undefined;
    global.__bulbCacheDict        = {};
    global.__bulbCacheArray       = [];
    global.__bulbCachePauseSave   = false;
    
    __BulbDiskCacheOpen();
    
    if (BULB_SPRITE_EDGE_AUTOTRACE)
    {
        var _totalStartTime = get_timer();
        var _autotraceArray = tag_get_asset_ids(BULB_SPRITE_AUTOTRACE_TAG, asset_sprite);
        
        if (BULB_VERBOSE) __BulbTrace("Starting autotrace of ", array_length(_autotraceArray), " sprites");
        
        global.__bulbCachePauseSave = true;
        
        var _i = 0;
        repeat(array_length(_autotraceArray))
        {
            var _spriteIndex = _autotraceArray[_i];
            var _sprite = new __BulbClassSprite(_spriteIndex, false);
            _sprite.__TraceAll();
            ++_i;
        }
        
        if (BULB_DISK_CACHE)
        {
            if (BULB_VERBOSE) __BulbTrace("Now saving disk cache buffer");
            global.__bulbCachePauseSave = false;
            buffer_save_ext(global.__bulbCacheBuffer, __BULB_DISK_CACHE_NAME, 0, buffer_tell(global.__bulbCacheBuffer));
        }
        
        if (BULB_VERBOSE) __BulbTrace("Autotrace ended. Time taken = ", (get_timer() - _totalStartTime)/1000, "ms");
    }
    
    if (BULB_SPRITE_EDGE_AUTOTAG && (__BULB_BUILD_TYPE == "run"))
    {
        if ((os_type != os_windows) && (os_type != os_macosx) && (os_type != os_linux))
        {
            __BulbTrace("BULB_SPRITE_EDGE_AUTOTAG not supported outside of Windows/MacOS/Linux export");
        }
        else if (!file_exists(GM_project_filename))
        {
            __BulbError("Could not verify existance of your project file\nEnsure that \"Disable file system sandbox\" is enabled\n(Project file path is \"", GM_project_filename, "\")");
        }
        else
        {
            global.__bulbProjectDirectory = filename_path(GM_project_filename);
        }
    }
}



function __BulbTrace()
{
    var _string = "";
    
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_debug_message("Bulb: " + _string);
}

function __BulbError()
{
    var _string = "";
    
    var _i = 0
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_debug_message("Bulb " + __BULB_VERSION + ": " + string_replace_all(_string, "\n", "\n          "));
    show_error("Bulb " + __BULB_VERSION + ":\n" + _string + "\n ", true);
}



function __BulbAddOcclusionHard(_vbuff)
{
    //Set up basic transforms to turn relative coordinates in arr_shadowGeometry[] into world-space coordinates
    var _sin = dsin(angle);
    var _cos = dcos(angle);
    
    var _xSin = xscale*_sin;
    var _xCos = xscale*_cos;
    var _ySin = yscale*_sin;
    var _yCos = yscale*_cos;
    
    if ((xscale < 0) ^^ (yscale < 0)) //If we have one negative scaling dimension...
    {
        //Loop through every line segment, remembering that we're storing coordinate data sequentially: { Ax1, Ay1, Bx1, Bx1,   Ax2, Ay2, Bx2, Bx2, ... }
        var _vertexArray = vertexArray;
        var _i = 0;
        repeat(array_length(_vertexArray) div 4)
        {
            //Collect first coordinate pair
            var _oldAx = _vertexArray[_i++];
            var _oldAy = _vertexArray[_i++];
            var _oldBx = _vertexArray[_i++];
            var _oldBy = _vertexArray[_i++];
            
            //...and transform
            var _newAx = x + _oldAx*_xCos + _oldAy*_ySin;
            var _newAy = y - _oldAx*_xSin + _oldAy*_yCos;
            var _newBx = x + _oldBx*_xCos + _oldBy*_ySin;
            var _newBy = y - _oldBx*_xSin + _oldBy*_yCos;
            
            //Add to the vertex buffer
            //Note that we reverse the winding order relative to below because we have one negative scaling dimension
            vertex_position_3d(_vbuff,   _newAx, _newAy,  0);           vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _newBx, _newBy,  0);           vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _newBx, _newBy,  __BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
            
            vertex_position_3d(_vbuff,   _newAx, _newAy,  0);           vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _newBx, _newBy,  __BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _newAx, _newAy,  __BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
        }
    }
    else
    {
        //Loop through every line segment, remembering that we're storing coordinate data sequentially: { Ax1, Ay1, Bx1, Bx1,   Ax2, Ay2, Bx2, Bx2, ... }
        var _vertexArray = vertexArray;
        var _i = 0;
        repeat(array_length(_vertexArray) div 4)
        {
            //Collect first coordinate pair
            var _oldAx = _vertexArray[_i++];
            var _oldAy = _vertexArray[_i++];
            var _oldBx = _vertexArray[_i++];
            var _oldBy = _vertexArray[_i++];
            
            //...and transform
            var _newAx = x + _oldAx*_xCos + _oldAy*_ySin;
            var _newAy = y - _oldAx*_xSin + _oldAy*_yCos;
            var _newBx = x + _oldBx*_xCos + _oldBy*_ySin;
            var _newBy = y - _oldBx*_xSin + _oldBy*_yCos;
            
            //Add to the vertex buffer
            vertex_position_3d(_vbuff,   _newAx, _newAy,  0);           vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _newBx, _newBy,  __BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _newBx, _newBy,  0);           vertex_colour(_vbuff,   c_black, 1);
            
            vertex_position_3d(_vbuff,   _newAx, _newAy,  0);           vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _newAx, _newAy,  __BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _newBx, _newBy,  __BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
        }
    }
}



function __BulbAddOcclusionSoft(_vbuff)
{
    //Set up basic transforms to turn relative coordinates in arr_shadowGeometry[] into world-space coordinates
    var _sin = dsin(angle);
    var _cos = dcos(angle);
    
    var _xSin = xscale*_sin;
    var _xCos = xscale*_cos;
    var _ySin = yscale*_sin;
    var _yCos = yscale*_cos;
    
    //Loop through every line segment, remembering that we're storing coordinate data sequentially: { Ax1, Ay1, Bx1, Bx1,   Ax2, Ay2, Bx2, Bx2, ... }
    var _vertexArray = vertexArray;
    var _i = 0;
    repeat(array_length(_vertexArray) div 4)
    {
        //Collect first coordinate pair
        var _oldAx = _vertexArray[_i++];
        var _oldAy = _vertexArray[_i++];
        var _oldBx = _vertexArray[_i++];
        var _oldBy = _vertexArray[_i++];
        
        //...and transform
        var _newAx = x + _oldAx*_xCos + _oldAy*_ySin;
        var _newAy = y - _oldAx*_xSin + _oldAy*_yCos;
        var _newBx = x + _oldBx*_xCos + _oldBy*_ySin;
        var _newBy = y - _oldBx*_xSin + _oldBy*_yCos;
        
        //Add to the vertex buffer
        vertex_position_3d(_vbuff,   _newAx, _newAy,  0);           vertex_texcoord(_vbuff,  1, 1);
        vertex_position_3d(_vbuff,   _newBx, _newBy,  __BULB_ZFAR); vertex_texcoord(_vbuff,  1, 1);
        vertex_position_3d(_vbuff,   _newBx, _newBy,  0);           vertex_texcoord(_vbuff,  1, 1);
        
        vertex_position_3d(_vbuff,   _newAx, _newAy,  0);           vertex_texcoord(_vbuff,  1, 1);
        vertex_position_3d(_vbuff,   _newAx, _newAy,  __BULB_ZFAR); vertex_texcoord(_vbuff,  1, 1);
        vertex_position_3d(_vbuff,   _newBx, _newBy,  __BULB_ZFAR); vertex_texcoord(_vbuff,  1, 1);
        
        //Add data for the soft shadows
        vertex_position_3d(_vbuff,   _newAx, _newAy,  __BULB_ZFAR); vertex_texcoord(_vbuff,  1, 0);
        vertex_position_3d(_vbuff,   _newAx, _newAy,  0);           vertex_texcoord(_vbuff,  0, 1);
        vertex_position_3d(_vbuff,   _newAx, _newAy,  __BULB_ZFAR); vertex_texcoord(_vbuff,  0, 0);
        
        vertex_position_3d(_vbuff,   _newAx, _newAy, -__BULB_ZFAR); vertex_texcoord(_vbuff,  0, 0); //Bit of a hack. We interpret this in __shdBulbSoftShadows
        vertex_position_3d(_vbuff,   _newAx, _newAy,  0);           vertex_texcoord(_vbuff,  0, 1);
        vertex_position_3d(_vbuff,   _newAx, _newAy,  __BULB_ZFAR); vertex_texcoord(_vbuff,  1, 0);
    }
}

function __BulbRectInRect(_ax1, _ay1, _ax2, _ay2, _bx1, _by1, _bx2, _by2)
{
    return !((_bx1 > _ax2) || (_bx2 < _ax1) || (_by1 > _ay2) || (_by2 < _ay1));
}

function __BulbEncodeTransformAsColor(_xscale, _yscale, _angle)
{
    _angle = (_angle < 0)? (360 - ((-_angle) mod 360)) : (_angle mod 360);
    
    //Angle is never exactly 1 so normalizedAngle can never be 65536
    var _normalizedAngle = floor(65536 * _angle / 360);
    
    var _red   = _normalizedAngle >> 8;
    var _green = _normalizedAngle & 0xFF;
    var _blue  = (_xscale >= 0) | ((_yscale >= 0) << 1);
    
    return make_color_rgb(_red, _green, _blue);
}
