/// @param spriteIndex
/// @param [checkForTag=true]

function __BulbClassSprite(_spriteIndex, _checkForTag = true) constructor
{
    static __global = __BulbGlobal();
    __global.__spriteDict[$ _spriteIndex] = self;
    
    if (!sprite_exists(_spriteIndex))
    {
        __BulbError("Sprite index ", _spriteIndex, " doesn't exist");
        return;
    }
    
    __spriteIndex = _spriteIndex;
    __imageArray  = array_create(sprite_get_number(__spriteIndex), undefined);
    
    //Size of the circle that encompasses the shape
    __radius = 0;
    
    var _i = 0;
    repeat(array_length(__imageArray))
    {
        __imageArray[@ _i] = new __BulbClassImage(__spriteIndex, _i);
        ++_i;
    }
    
    if (_checkForTag) __EnsureTag();
    
    
    
    static __TraceAll = function()
    {
        __radius = 0;
        
        var _i = 0;
        repeat(array_length(__imageArray))
        {
            __imageArray[@ _i].__GetEdgeArray();
            __radius = max(__radius, __imageArray[_i].__radius);
            ++_i;
        }
    }
    
    static __EnsureTag = function()
    {
        if (!BULB_TAG_ASSETS_ON_USE || (__BULB_BUILD_TYPE != "run")) return;
        
        var _spriteName = sprite_get_name(__spriteIndex);
        var _path = __global.__projectDirectory + "sprites/" + _spriteName + "/" + _spriteName + ".yy";
        
        if (!file_exists(_path))
        {
            __BulbError("Could not find \"", _path, "\"\nSprite was ", _spriteName, " (index ", __spriteIndex, ")");
            return;
        }
        
        var _buffer = buffer_load(_path);
        var _string = buffer_read(_buffer, buffer_text);
        buffer_delete(_buffer);
        
        var _pos = string_pos("  \"tags\": [", _string);
        if (_pos <= 0)
        {
            _string = string_insert("\n  \"tags\": [\n    \"" + BULB_TRACE_TAG + "\",\n  ],", _string, string_length(_string)-2);
            
            var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
            buffer_write(_buffer, buffer_text, _string);
            buffer_save(_buffer, _path);
            buffer_delete(_buffer);
            
            __BulbTrace("Added tag \"", BULB_TRACE_TAG, "\" to ", sprite_get_name(__spriteIndex));
        }
        else if (string_pos_ext("\"" + BULB_TRACE_TAG + "\"", _string, _pos) <= 0)
        {
            _string = string_insert("    \"" + BULB_TRACE_TAG + "\",", _string, _pos+12);
            
            var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
            buffer_write(_buffer, buffer_text, _string);
            buffer_save(_buffer, _path);
            buffer_delete(_buffer);
            
            __BulbTrace("Added tag \"", BULB_TRACE_TAG, "\" to ", sprite_get_name(__spriteIndex));
        }
    }
}