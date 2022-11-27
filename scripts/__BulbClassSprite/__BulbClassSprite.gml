/// @param spriteIndex
/// @param [checkForTag=true]

function __BulbClassSprite(_spriteIndex, _checkForTag = true) constructor
{
    global.__bulbSpriteDict[$ _spriteIndex] = self;
    
    __spriteIndex = _spriteIndex;
    __imageArray = array_create(sprite_get_number(__spriteIndex), undefined);
    
    var _i = 0;
    repeat(array_length(__imageArray))
    {
        __imageArray[@ _i] = new __BulbClassImage(__spriteIndex, _i);
        ++_i;
    }
    
    if (_checkForTag) __EnsureTag();
    
    
    
    static __TraceAll = function()
    {
        var _i = 0;
        repeat(array_length(__imageArray))
        {
            __imageArray[@ _i].__GetTrace();
            ++_i;
        }
    }
    
    static __EnsureTag = function()
    {
        if (!BULB_SPRITE_EDGE_AUTOTAG || (__BULB_BUILD_TYPE != "run")) return;
        
        var _spriteName = sprite_get_name(__spriteIndex);
        var _path = global.__bulbProjectDirectory + "sprites/" + _spriteName + "/" + _spriteName + ".yy";
        
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
            _string = string_insert("\n  \"tags\": [\n    \"" + BULB_AUTOTRACE_TAG + "\",\n  ],", _string, string_length(_string)-2);
            
            var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
            buffer_write(_buffer, buffer_text, _string);
            buffer_save(_buffer, _path);
            buffer_delete(_buffer);
        }
        else if (string_pos_ext("\"" + BULB_AUTOTRACE_TAG + "\"", _string, _pos) <= 0)
        {
            _string = string_insert("    \"" + BULB_AUTOTRACE_TAG + "\",", _string, _pos+12);
            
            var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
            buffer_write(_buffer, buffer_text, _string);
            buffer_save(_buffer, _path);
            buffer_delete(_buffer);
        }
    }
}