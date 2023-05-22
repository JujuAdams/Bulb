/// @param spriteIndex
/// @param imageIndex

function __BulbClassImage(_spriteIndex, _imageIndex) constructor
{
    static __global = __BulbGlobal();
    
    __spriteIndex = _spriteIndex;
    __imageIndex  = _imageIndex;
    
    //Size of the circle that encompasses the shape
    __radius = 0;
    
    __hash   = undefined;
    __onDisk = undefined;
    
    __edgeArray = undefined;
    
    
    
    static __GetName = function()
    {
        return (sprite_get_name(__spriteIndex) + "." + string(__imageIndex));
    }
    
    static __GetEdgeArray = function()
    {
        if (__edgeArray == undefined)
        {
            if (BULB_VERBOSE) var _t = get_timer();
            
            if (__DiskCheck()) __DiskLoad();
            
            if (BULB_VERBOSE)
            {
                if (__edgeArray != undefined) __BulbTrace("Loaded ", __GetName(), " from disk cache (", (get_timer() - _t)/1000, "ms)");
            }
        }
        
        if (__edgeArray == undefined)
        {
            if (BULB_VERBOSE) var _t = get_timer();
            
            var _buffer = __GetBuffer();
            
            //We'll likely need the hash later so we can save a bit of time by calculating it now
            if (BULB_USE_DISK_CACHE && (__BULB_BUILD_TYPE == "run")) __GetHash(_buffer);
            
            var _result = __BulbTraceBufferToEdgeArray(_buffer,
                                                       sprite_get_width(__spriteIndex) + 2, sprite_get_height(__spriteIndex) + 2, 2,
                                                       -1 - sprite_get_xoffset(__spriteIndex), -1 - sprite_get_yoffset(__spriteIndex),
                                                       false, true, BULB_TRACE_EPSILON);
            
            __edgeArray = _result.__edgeArray;
            __radius    = _result.__radius;
            
            buffer_delete(_buffer);
            
            __DiskSave();
            
            if (BULB_VERBOSE) __BulbTrace("Traced ", __GetName(), " (", (get_timer() - _t)/1000, "ms)");
        }
        
        return __edgeArray;
    }
    
    static __DiskCheck = function()
    {
        if (!BULB_USE_DISK_CACHE) return false;
        
        if (__onDisk == undefined)
        {
            __onDisk = variable_struct_exists(__global.__cacheDict, __GetName());
        }
        
        return __onDisk;
    }
    
    static __DiskLoad = function()
    {
        if (!BULB_USE_DISK_CACHE) return;
        if (!__DiskCheck()) return;
        
        var _buffer = __global.__cacheBuffer;
        var _oldTell = buffer_tell(_buffer);
        
        var _bufferPos = __global.__cacheDict[$ __GetName()];
        buffer_seek(_buffer, buffer_seek_start, _bufferPos);
        
        var _expectedFinalTell = _bufferPos + buffer_read(_buffer, buffer_u64);
        
        var _diskName = buffer_read(_buffer, buffer_string);
        if (_diskName != __GetName())
        {
            __BulbTrace("Warning! Name in cache (", _diskName, ") doesn't match expected name (", __GetName(), ")");
            
            __onDisk = false;
            buffer_seek(_buffer, buffer_seek_start, _oldTell);
            return;
        }
        
        var _diskHash  = buffer_read(_buffer, buffer_string);
        var _buildDate = buffer_read(_buffer, buffer_f64);
        
        if (__BULB_BUILD_TYPE == "run")
        {
            if (__GetHash() != _diskHash)
            {
                if (BULB_VERBOSE) __BulbTrace("Hash for ", __GetName(), " (", __GetHash(), ") doesn't match hash on disk (", _diskHash, ")");
                
                __onDisk = false;
                buffer_seek(_buffer, buffer_seek_start, _oldTell);
                return;
            }
        }
        else
        {
            if (GM_build_date != _buildDate)
            {
                if (BULB_VERBOSE) __BulbTrace("Current build date for ", __GetName(), " (", string_format(GM_build_date, 0, 10), ") doesn't match build date on disk (", string_format(_buildDate, 0, 10), ")");
                
                __onDisk = false;
                buffer_seek(_buffer, buffer_seek_start, _oldTell);
                return;
            }
        }
        
        __radius = buffer_read(_buffer, buffer_f64);
        var _pointCount = buffer_read(_buffer, buffer_u64);
        __edgeArray = array_create(_pointCount, undefined);
        
        var _i = 0;
        repeat(_pointCount)
        {
            __edgeArray[@ _i] = buffer_read(_buffer, buffer_s16);
            ++_i;
        }
        
        if (buffer_tell(_buffer) != _expectedFinalTell)
        {
            __BulbTrace("Warning! Final buffer position (", buffer_tell(_buffer), ") did not match expected (", _expectedFinalTell, ")");
            
            __edgeArray = undefined;
            
            __onDisk = false;
            buffer_seek(_buffer, buffer_seek_start, _oldTell);
            return;
        }
        
        buffer_seek(_buffer, buffer_seek_start, _oldTell);
        return __edgeArray;
    }
    
    static __DiskSave = function()
    {
        if (!BULB_USE_DISK_CACHE) return;
        
        __onDisk = true;
        
        var _buffer = __global.__cacheBuffer;
        
        buffer_seek(_buffer, buffer_seek_relative, -8);
        
        var _byteSizePosition = buffer_tell(_buffer);
        buffer_write(_buffer, buffer_u64, 0);
        
        buffer_write(_buffer, buffer_string, __GetName());
        buffer_write(_buffer, buffer_string, (__BULB_BUILD_TYPE == "run")? __GetHash() : "<undefined>");
        buffer_write(_buffer, buffer_f64,    GM_build_date);
        buffer_write(_buffer, buffer_f64,    __radius);
        
        buffer_write(_buffer, buffer_u64, array_length(__edgeArray));
        var _i = 0;
        repeat(array_length(__edgeArray))
        {
            buffer_write(_buffer, buffer_s16, __edgeArray[_i]);
            ++_i;
        }
        
        var _byteSize = buffer_tell(_buffer) - _byteSizePosition;
        buffer_poke(_buffer, _byteSizePosition, buffer_u64, _byteSize);
        buffer_write(_buffer, buffer_u64, 0);
        
        if (!__global.__cachePauseSave) buffer_save_ext(_buffer, __BULB_DISK_CACHE_NAME, 0, buffer_tell(_buffer));
    }
    
    static __GetHash = function(_buffer = undefined)
    {
        if (__hash == undefined)
        {
            var _destroyBuffer = false;
            
            if (_buffer == undefined)
            {
                _buffer = __GetBuffer();
                _destroyBuffer = true;
            }
            
            __hash = buffer_md5(_buffer, 0, buffer_get_size(_buffer));
            
            if (_destroyBuffer) buffer_delete(_buffer);
        }
        
        return __hash;
    }
    
    static __GetBuffer = function()
    {
        var _surfaceWidth  = sprite_get_width( __spriteIndex) + 2;
        var _surfaceHeight = sprite_get_height(__spriteIndex) + 2;
        var _surface = surface_create(_surfaceWidth, _surfaceHeight);
        
        surface_set_target(_surface);
        draw_clear_alpha(c_black, 0.0);
        draw_sprite(__spriteIndex, __imageIndex, 1 + sprite_get_xoffset(__spriteIndex), 1 + sprite_get_yoffset(__spriteIndex));
        surface_reset_target();
        
        var _buffer = buffer_create(4*_surfaceWidth*_surfaceHeight, buffer_fixed, 1);
        buffer_get_surface(_buffer, _surface, 0);
        buffer_seek(_buffer, buffer_seek_start, 0);
        surface_free(_surface);
        
        return _buffer;
    }
}