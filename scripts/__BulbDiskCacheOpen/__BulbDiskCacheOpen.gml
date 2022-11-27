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
            
            global.__bulbCacheDict = {};
            var _entryArray = [];
            
            var _buffer = global.__bulbCacheBuffer;
            
            var _pos = 0;
            var _byteSize = buffer_read(_buffer, buffer_u64);
            while(_byteSize > 0)
            {
                var _name = buffer_read(_buffer, buffer_string);
                
                array_push(_entryArray, {
                    __position: _pos,
                    __byteSize: _byteSize,
                    __name:     _name,
                    __delete:   false,
                });
                
                buffer_seek(_buffer, buffer_seek_start, _pos + _byteSize);
                _pos += _byteSize;
                _byteSize = buffer_read(_buffer, buffer_u64);
            }
            
            //Detect any duplicate entries that need to be deleted
            var _anyConflicts = false;
            var _dict = {};
            
            var _i = array_length(_entryArray)-1;
            repeat(_i+1)
            {
                var _entry = _entryArray[_i];
                var _name = _entry.__name;
                
                if (variable_struct_exists(_dict, _name))
                {
                    __BulbTrace("Found older version of ", _name);
                    
                    _entry.__delete = true;
                    _anyConflicts = true;
                }
                else
                {
                    _dict[$ _name] = _entry;
                }
                
                --_i;
            }
            
            if (_anyConflicts)
            {
                var _deletedBytes = 0;
                
                var _i = 0;
                repeat(array_length(_entryArray))
                {
                    var _entry = _entryArray[_i];
                    var _name = _entry.__name;
                    
                    if (_entry.__delete)
                    {
                        _deletedBytes += _entry.__byteSize;
                        array_delete(_entryArray, _i, 1);
                    }
                    else
                    {
                        _entry.__position -= _deletedBytes;
                        ++_i;
                    }
                }
                
                var _newBuffer = buffer_create(buffer_get_size(_buffer), buffer_grow, 1);
                var _pos = 0;
                
                var _i = 0;
                repeat(array_length(_entryArray))
                {
                    var _entry = _entryArray[_i];
                    buffer_copy(_buffer, _entry.__position, _entry.__byteSize, _newBuffer, _pos);
                    ++_i;
                }
                
                global.__bulbCacheBuffer = _newBuffer;
                buffer_delete(_buffer);
                
                buffer_save_ext(_newBuffer, __BULB_DISK_CACHE_NAME, 0, buffer_tell(_newBuffer));
            }
            
            
            
            //Now build the quick lookup dictionary
            var _i = 0;
            repeat(array_length(_entryArray))
            {
                var _entry = _entryArray[_i];
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