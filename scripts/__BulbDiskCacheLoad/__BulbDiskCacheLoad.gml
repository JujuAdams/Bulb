function __BulbDiskCacheLoad()
{
    static _global = __BulbGlobal();
    
    if (BULB_USE_DISK_CACHE)
    {
        if (_global.__cacheBuffer == undefined)
        {
            if (BULB_VERBOSE) var _t = get_timer();
            
            if (file_exists(__BULB_DISK_CACHE_NAME))
            {
                _global.__cacheBuffer = buffer_load(__BULB_DISK_CACHE_NAME);
            }
            else
            {
                _global.__cacheBuffer = buffer_create(1024, buffer_grow, 1);
            }
            
            _global.__cacheDict = {};
            var _entryArray = [];
            
            var _buffer = _global.__cacheBuffer;
            
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
            var _anyDeleted = false;
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
                    _anyDeleted = true;
                }
                else
                {
                    var _checkName = _name;
                    if (string_count(".", _name) == 1) _checkName = string_copy(_name, 1, string_pos(".", _name)-1);
                    
                    var _assetIndex = asset_get_index(_checkName);
                    if (_assetIndex < 0)
                    {
                        __BulbTrace("Asset \"", _name, "\" no longer exists");
                        
                        _entry.__delete = true;
                        _anyDeleted = true;
                    }
                    else
                    {
                        _dict[$ _name] = _entry;
                    }
                }
                
                --_i;
            }
            
            if (_anyDeleted)
            {
                var _newBuffer = buffer_create(buffer_get_size(_buffer), buffer_grow, 1);
                
                var _pos = 0;
                var _i = 0;
                repeat(array_length(_entryArray))
                {
                    var _entry = _entryArray[_i];
                    var _name = _entry.__name;
                    
                    if (_entry.__delete)
                    {
                        array_delete(_entryArray, _i, 1);
                    }
                    else
                    {
                        buffer_copy(_buffer, _entry.__position, _entry.__byteSize, _newBuffer, _pos);
                        _entry.__position = _pos;
                        _pos += _entry.__byteSize;
                        
                        ++_i;
                    }
                }
                
                buffer_delete(_buffer);
                _global.__cacheBuffer = _newBuffer;
                buffer_seek(_global.__cacheBuffer, buffer_seek_start, _pos);
                buffer_write(_global.__cacheBuffer, buffer_u64, 0);
                
                buffer_save_ext(_newBuffer, __BULB_DISK_CACHE_NAME, 0, buffer_tell(_newBuffer));
            }
            
            //Now build the quick lookup dictionary
            var _i = 0;
            repeat(array_length(_entryArray))
            {
                var _entry = _entryArray[_i];
                _global.__cacheDict[$ _entry.__name] = _entry.__position;
                ++_i;
            }
            
            if (BULB_VERBOSE) __BulbTrace("Disk cache loaded, took ", (get_timer() - _t)/1000, "ms");
        }
        else
        {
            if (BULB_VERBOSE) __BulbTrace("Disk cache already loaded");
        }
    }
}