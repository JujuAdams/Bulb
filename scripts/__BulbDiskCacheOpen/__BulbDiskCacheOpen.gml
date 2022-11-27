function __BulbDiskCacheOpen()
{
    if (BULB_DISK_CACHE)
    {
        if (global.__bulbCacheBuffer == undefined)
        {
            if (BULB_VERBOSE) var _t = get_timer();
            
            if (file_exists(__BULB_DISK_CACHE_NAME))
            {
                global.__bulbCacheBuffer = buffer_load(__BULB_DISK_CACHE_NAME);
            }
            else
            {
                global.__bulbCacheBuffer = buffer_create(1024, buffer_grow, 1);
            }
            
            global.__bulbCacheDict  = {};
            global.__bulbCacheArray = [];
            
            var _buffer = global.__bulbCacheBuffer;
            
            var _pos = 0;
            var _byteSize = buffer_read(_buffer, buffer_u64);
            while(_byteSize > 0)
            {
                var _name = buffer_read(_buffer, buffer_string);
                
                array_push(global.__bulbCacheArray, {
                    __position: _pos,
                    __byteSize: _byteSize,
                    __name:     _name,
                });
                
                buffer_seek(_buffer, buffer_seek_start, _pos + _byteSize);
                _pos += _byteSize;
                _byteSize = buffer_read(_buffer, buffer_u64);
            }
            
            var _i = array_length(_entriesArray)-1;
            repeat(_i+1)
            {
                
                
                --_i;
            }
            
            //Now build the quick lookup dictionary
            var _i = 0;
            repeat(array_length(global.__bulbCacheArray))
            {
                var _entry = global.__bulbCacheArray[_i];
                global.__bulbCacheDict[$ _entry.__name] = _entry.__position;
                ++_i;
            }
            
            if (BULB_VERBOSE) __BulbTrace("Disk cache open, took ", (get_timer() - _t)/1000, "ms");
        }
        else
        {
            if (BULB_VERBOSE) __BulbTrace("Disk cache already open");
        }
    }
}