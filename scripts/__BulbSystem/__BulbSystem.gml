#macro __BULB_VERSION                "20.4.0 alpha"
#macro __BULB_DATE                   "2023-05-14"
#macro __BULB_FORCE_PRODUCTION_MODE  false
#macro __BULB_BUILD_TYPE             (__BULB_FORCE_PRODUCTION_MODE? "exe" : GM_build_type)
#macro __BULB_DISK_CACHE_NAME        ((__BULB_BUILD_TYPE == "run")? "BulbCacheDev.dat" : "BulbCache.dat")
#macro __BULB_ARRAY_EDGE_SIZE        8

__BulbInitialize();

function __BulbInitialize()
{
    static _initialized = false;
    if (_initialized) return;
    _initialized = true;

    __BulbTrace("Welcome to Bulb by @jujuadams! This is version " + __BULB_VERSION + ", " + __BULB_DATE);
    
    static _global = __BulbGlobal();
    
    //Create a couple vertex formats
    vertex_format_begin();
    vertex_format_add_position_3d();
    vertex_format_add_custom(vertex_type_float4, vertex_usage_normal);
    _global.__vFormatHard = vertex_format_end();
    
    vertex_format_begin();
    vertex_format_add_position_3d();
    vertex_format_add_custom(vertex_type_float3, vertex_usage_texcoord);
    _global.__vFormatSoft = vertex_format_end();
    
    __BulbDiskCacheLoad();
    
    if (BULB_TRACE_TAGGED_ASSETS_ON_BOOT)
    {
        _global.__cachePauseSave = true;
        
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
        _global.__cachePauseSave = false;
        if (BULB_USE_DISK_CACHE) buffer_save_ext(_global.__cacheBuffer, __BULB_DISK_CACHE_NAME, 0, buffer_tell(_global.__cacheBuffer));
    }
    
    if (BULB_TAG_ASSETS_ON_USE && (__BULB_BUILD_TYPE == "run"))
    {
        if ((os_type != os_windows) && (os_type != os_macosx) && (os_type != os_linux))
        {
            __BulbTrace("Warning! BULB_TAG_ASSETS_ON_USE not supported outside of Windows/MacOS/Linux export");
        }
        else if (!file_exists(GM_project_filename))
        {
            __BulbError("Could not find your project file\nEnsure that \"Disable file system sandbox\" is enabled\n(Project file path is \"", GM_project_filename, "\")");
        }
        else
        {
            _global.__projectDirectory = filename_path(GM_project_filename);
        }
    }
}

function __BulbGlobal()
{
    static _struct = {
        __vFormatHard: undefined,
        __vFormatSoft: undefined,
        
        __spriteDict:  {},
        __tilesetDict: {},
        
        __projectDirectory: undefined,
        __cacheBuffer:      undefined,
        __cacheDict:        {},
        __cachePauseSave:   false,
    };
    
    return _struct;
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
    
    show_debug_message("Bulb: " + string_replace_all(_string, "\n", "\n          "));
    show_error("Bulb:\n" + _string + "\n ", true);
}

function __BulbRectInRect(_ax1, _ay1, _ax2, _ay2, _bx1, _by1, _bx2, _by2)
{
    return !((_bx1 > _ax2) || (_bx2 < _ax1) || (_by1 > _ay2) || (_by2 < _ay1));
}