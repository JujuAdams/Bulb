/// @param spriteIndex
/// @param imageIndex

function __BulbClassImage(_spriteIndex, _imageIndex) constructor
{
    __spriteIndex = _spriteIndex;
    __imageIndex  = _imageIndex;
    
    __hash   = undefined;
    __onDisk = undefined;
    
    __trace = undefined;
    
    
    
    static __GetName = function()
    {
        return (sprite_get_name(__spriteIndex) + "." + string(__imageIndex));
    }
    
    static __GetTrace = function()
    {
        if (__trace == undefined)
        {
            if (__DiskCheck()) __DiskLoad();
        }
        
        if (__trace == undefined)
        {
            var _buffer = __GetBuffer();
            
            //We'll likely need the hash later so we can save a bit of time by calculating it now
            if (BULB_USE_DISK_CACHE && (__BULB_BUILD_TYPE == "run")) __GetHash(_buffer);
            
            if (BULB_VERBOSE) var _t = get_timer();
            __trace = __BulbTraceBuffer(_buffer,
                                        sprite_get_width(__spriteIndex) + 2, sprite_get_height(__spriteIndex) + 2, 2,
                                        -1 - sprite_get_xoffset(__spriteIndex), -1 - sprite_get_yoffset(__spriteIndex),
                                        false, 1/255, true);
            if (BULB_VERBOSE) __BulbTrace("Tracing ", __GetName(), " buffer took ", (get_timer() - _t)/1000, "ms");
            buffer_delete(_buffer);
            
            __DiskSave();
        }
        
        return __trace;
    }
    
    static __DiskCheck = function()
    {
        if (!BULB_USE_DISK_CACHE) return false;
        
        if (__onDisk == undefined)
        {
            __onDisk = variable_struct_exists(global.__bulbCacheDict, __GetName());
        }
        
        return __onDisk;
    }
    
    static __DiskLoad = function()
    {
        if (!BULB_USE_DISK_CACHE) return;
        if (!__DiskCheck()) return;
        
        if (BULB_VERBOSE) var _t = get_timer();
        
        var _buffer = global.__bulbCacheBuffer;
        var _oldTell = buffer_tell(_buffer);
        
        var _bufferPos = global.__bulbCacheDict[$ __GetName()];
        buffer_seek(_buffer, buffer_seek_start, _bufferPos);
        
        var _expectedFinalTell = _bufferPos + buffer_read(_buffer, buffer_u64);
        
        var _diskName = buffer_read(_buffer, buffer_string);
        if (_diskName != __GetName())
        {
            if (BULB_VERBOSE) __BulbTrace("Name in cache (", _diskName, ") doesn't match expected name (", __GetName(), ")");
            
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
        
        var _loopCount = buffer_read(_buffer, buffer_u64);
        __trace = array_create(_loopCount, undefined);
        
        var _i = 0;
        repeat(_loopCount)
        {
            var _loopLength = buffer_read(_buffer, buffer_u64);
            var _loop = array_create(_loopLength, undefined);
            __trace[@ _i] = _loop;
            
            var _j = 0;
            repeat(_loopLength)
            {
                _loop[@ _j] = buffer_read(_buffer, buffer_s16);
                ++_j;
            }
            
            ++_i;
        }
        
        if (buffer_tell(_buffer) != _expectedFinalTell)
        {
            if (BULB_VERBOSE) __BulbTrace("Warning! Final buffer position (", buffer_tell(_buffer), ") did not match expected (", _expectedFinalTell, ")");
            
            __trace = undefined;
            
            __onDisk = false;
            buffer_seek(_buffer, buffer_seek_start, _oldTell);
            return;
        }
        
        if (BULB_VERBOSE) __BulbTrace("Loading trace of ", __GetName(), " from disk cache took ", (get_timer() - _t)/1000, "ms");
        
        buffer_seek(_buffer, buffer_seek_start, _oldTell);
        return __trace;
    }
    
    static __DiskSave = function()
    {
        if (!BULB_USE_DISK_CACHE) return;
        
        __onDisk = true;
        
        var _buffer = global.__bulbCacheBuffer;
        
        buffer_seek(_buffer, buffer_seek_relative, -8);
        
        var _byteSizePosition = buffer_tell(_buffer);
        buffer_write(_buffer, buffer_u64, 0);
        
        buffer_write(_buffer, buffer_string, __GetName());
        buffer_write(_buffer, buffer_string, (__BULB_BUILD_TYPE == "run")? __GetHash() : "<undefined>");
        buffer_write(_buffer, buffer_f64,    GM_build_date);
        
        buffer_write(_buffer, buffer_u64, array_length(__trace));
        var _i = 0;
        repeat(array_length(__trace))
        {
            var _loop = __trace[_i];
            buffer_write(_buffer, buffer_u64, array_length(_loop));
            
            var _j = 0;
            repeat(array_length(_loop))
            {
                buffer_write(_buffer, buffer_s16, _loop[_j]);
                ++_j;
            }
            
            ++_i;
        }
        
        var _byteSize = buffer_tell(_buffer) - _byteSizePosition;
        buffer_poke(_buffer, _byteSizePosition, buffer_u64, _byteSize);
        buffer_write(_buffer, buffer_u64, 0);
        
        if (!global.__bulbCachePauseSave) buffer_save_ext(_buffer, __BULB_DISK_CACHE_NAME, 0, buffer_tell(_buffer));
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
        if (BULB_VERBOSE) var _t = get_timer();
        
        var _surfaceWidth  = sprite_get_width( __spriteIndex) + 2;
        var _surfaceHeight = sprite_get_height(__spriteIndex) + 2;
        var _surface = surface_create(_surfaceWidth, _surfaceHeight);
        
        surface_set_target(_surface);
        draw_clear_alpha(c_black, 0.0);
        draw_sprite(__spriteIndex, __imageIndex, 1 - sprite_get_xoffset(__spriteIndex), 1 - sprite_get_yoffset(__spriteIndex));
        surface_reset_target();
        
        var _buffer = buffer_create(4*_surfaceWidth*_surfaceHeight, buffer_fixed, 1);
        buffer_get_surface(_buffer, _surface, 0);
        buffer_seek(_buffer, buffer_seek_start, 0);
        surface_free(_surface);
        
        if (BULB_VERBOSE) __BulbTrace("Building buffer for ", __GetName(), " took ", (get_timer() - _t)/1000, "ms");
        
        return _buffer;
    }
}