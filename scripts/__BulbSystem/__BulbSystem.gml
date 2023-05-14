#macro __BULB_VERSION                "21.0.0"
#macro __BULB_DATE                   "2022-08-14"
#macro __BULB_ON_DIRECTX             ((os_browser == browser_not_a_browser) && ((os_type == os_windows) || (os_type == os_xboxone) || (os_type == os_uwp) || (os_type == os_winphone) || (os_type == os_win8native)))
#macro __BULB_ZFAR                   16000
#macro __BULB_FLIP_CAMERA_Y          __BULB_ON_DIRECTX
#macro __BULB_PARTIAL_CLEAR          true
#macro __BULB_SQRT_2                 1.41421356237
#macro __BULB_NORMAL_CLEAR_COLOUR    #7F7FFF
#macro __BULB_FORCE_PRODUCTION_MODE  false
#macro __BULB_BUILD_TYPE             (__BULB_FORCE_PRODUCTION_MODE? "exe" : GM_build_type)
#macro __BULB_DISK_CACHE_NAME        ((__BULB_BUILD_TYPE == "run")? "BulbCacheDev.dat" : "BulbCache.dat")
#macro __BULB_ARRAY_VERTEX_SIZE      6

__BulbInitialize();

function __BulbInitialize()
{
    static _initialized = false;
    if (_initialized) return;
    _initialized = true;
    
    __BulbTrace("Welcome to Bulb by @jujuadams! This is version " + __BULB_VERSION + ", " + __BULB_DATE);
    
    vertex_format_begin();
    vertex_format_add_position_3d();
    vertex_format_add_colour();
    global.__bulbFormatPassthrough = vertex_format_end();
    
    vertex_format_begin();
    vertex_format_add_position_3d();
    vertex_format_add_texcoord();
    global.__bulbFormatHard = vertex_format_end();
    
    vertex_format_begin();
    vertex_format_add_position_3d();
    vertex_format_add_texcoord();
    global.__bulbFormatSoft = vertex_format_end();
    
    global.__bulbSpriteDict  = {};
    global.__bulbTilesetDict = {};
    
    global.__bulbProjectDirectory = undefined;
    global.__bulbCacheBuffer      = undefined;
    global.__bulbCacheDict        = {};
    global.__bulbCachePauseSave   = false;
    
    __BulbDiskCacheLoad();
    
    if (BULB_TRACE_TAGGED_ASSETS_ON_BOOT)
    {
        global.__bulbCachePauseSave = true;
        
        //Sprites
        if (BULB_VERBOSE) var _t = get_timer();
        var _array = tag_get_asset_ids(BULB_TRACE_TAG, asset_sprite);
        if (BULB_VERBOSE) __BulbTrace("Starting on-boot trace of ", array_length(_array), " sprites");
        
        var _i = 0;
        repeat(array_length(_array))
        {
            var _spriteIndex = _array[_i];
            var _sprite = new __BulbClassSprite(_spriteIndex, false);
            _sprite.__TraceAll();
            ++_i;
        }
        
        if (BULB_VERBOSE) __BulbTrace("Sprite trace ended (", (get_timer() - _t)/1000, "ms)");
        
        //Tilemaps
        if (BULB_VERBOSE) var _t = get_timer();
        var _array = tag_get_asset_ids(BULB_TRACE_TAG, asset_tiles);
        if (BULB_VERBOSE) __BulbTrace("Starting on-boot trace of ", array_length(_array), " tilesets");
        
        var _i = 0;
        repeat(array_length(_array))
        {
            var _tilesetIndex = _array[_i];
            var _tileset = new __BulbClassTileset(_tilesetIndex, false);
            _tileset.__GetTileDictionary();
            ++_i;
        }
        
        if (BULB_VERBOSE) __BulbTrace("Tileset trace ended (", (get_timer() - _t)/1000, "ms)");
        
        //Actually save the cache to disk now
        global.__bulbCachePauseSave = false;
        if (BULB_USE_DISK_CACHE) buffer_save_ext(global.__bulbCacheBuffer, __BULB_DISK_CACHE_NAME, 0, buffer_tell(global.__bulbCacheBuffer));
    }
    
    if (BULB_TAG_ASSETS_ON_USE && (__BULB_BUILD_TYPE == "run"))
    {
        if ((os_type != os_windows) && (os_type != os_macosx) && (os_type != os_linux))
        {
            __BulbTrace("Warning! BULB_TAG_ASSETS_ON_USE not supported outside of Windows/MacOS/Linux export");
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

function __BulbRectInRect(_ax1, _ay1, _ax2, _ay2, _bx1, _by1, _bx2, _by2)
{
    return !((_bx1 > _ax2) || (_bx2 < _ax1) || (_by1 > _ay2) || (_by2 < _ay1));
}