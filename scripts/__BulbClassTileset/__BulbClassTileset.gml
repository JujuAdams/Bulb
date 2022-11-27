/// @param tileset
/// @param [checkForTag=true]

function __BulbClassTileset(_tileset, _checkForTag = true) constructor
{
    global.__bulbTilesetDict[$ _tileset] = self;
    
    __tileset = _tileset;
    __hash    = undefined;
    
    layer_set_target_room(0);
    var _layer   = layer_create(0);
    var _tilemap = layer_tilemap_create(_layer, 0, 0, _tileset, 1, 1);
    
    __tileWidth  = tilemap_get_tile_width(_tilemap);
    __tileHeight = tilemap_get_tile_height(_tilemap);
    
    layer_tilemap_destroy(_tilemap);
    layer_destroy(_layer);
    layer_reset_target_room();
    
    var _tilesetTexture = tileset_get_texture(_tileset);
    var _tilesetUVs     = tileset_get_uvs(_tileset);
    var _textureWidth   = (_tilesetUVs[2] - _tilesetUVs[0]) / texture_get_texel_width(_tilesetTexture);
    var _textureHeight  = (_tilesetUVs[3] - _tilesetUVs[1]) / texture_get_texel_height(_tilesetTexture);
    
    __tilesWide = _textureWidth  / (__tileWidth  + 4);
    __tilesHigh = _textureHeight / (__tileHeight + 4);
    
    if (_checkForTag) __EnsureTag();
    
    
    
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
        var _extTileWidth  = 4 + __tileWidth;
        var _extTileHeight = 4 + __tileHeight;
        
        var _tilesetTexture = tileset_get_texture(__tileset);
        var _tilesetUVs     = tileset_get_uvs(    __tileset);
        var _surfaceWidth  = (_tilesetUVs[2] - _tilesetUVs[0]) / texture_get_texel_width( _tilesetTexture);
        var _surfaceHeight = (_tilesetUVs[3] - _tilesetUVs[1]) / texture_get_texel_height(_tilesetTexture);
        
        var _surface = surface_create(_surfaceWidth, _surfaceHeight);
        surface_set_target(_surface);
        draw_clear_alpha(c_black, 0.0);
        
        //Draw the raw tileset to the surface
        draw_primitive_begin_texture(pr_trianglestrip, _tilesetTexture);
        draw_vertex_texture_colour(            0,              0, 0, 0, c_white, 1.0);
        draw_vertex_texture_colour(            0, _surfaceHeight, 0, 1, c_white, 1.0);
        draw_vertex_texture_colour(_surfaceWidth,              0, 1, 0, c_white, 1.0);
        draw_vertex_texture_colour(_surfaceWidth, _surfaceHeight, 1, 1, c_white, 1.0);
        draw_primitive_end();
        
        //Erase gutters
        gpu_set_blendmode(bm_subtract);
        draw_set_colour(c_white);
        draw_set_alpha(1.0);
        
        var _x = 0;
        repeat(__tilesWide)
        {
            draw_line(_x, -1, _x, _surfaceHeight);
            draw_line(_x+1, -1, _x+1, _surfaceHeight);
            _x += _extTileWidth;
            draw_line(_x-2, -1, _x-2, _surfaceHeight);
            draw_line(_x-1, -1, _x-1, _surfaceHeight);
        }
        
        var _y = 0;
        repeat(__tilesHigh)
        {
            draw_line(-1, _y, _surfaceWidth, _y);
            draw_line(-1, _y+1, _surfaceWidth, _y+1);
            _y += _extTileHeight;
            draw_line(-1, _y-2, _surfaceWidth, _y-2);
            draw_line(-1, _y-1, _surfaceWidth, _y-1);
        }
        
        gpu_set_blendmode(bm_normal);
        
        surface_reset_target();
        
        //Turn the surface into a buffer for analysis
        var _buffer = buffer_create(4*_surfaceWidth*_surfaceHeight, buffer_fixed, 1);
        buffer_get_surface(_buffer, _surface, 0);
        buffer_seek(_buffer, buffer_seek_start, 0);
        surface_free(_surface);
        
        return _buffer;
    }
    
    static __EnsureTag = function()
    {
        if (!BULB_SPRITE_EDGE_AUTOTAG || (__BULB_BUILD_TYPE != "run")) return;
        
        var _tilesetName = tileset_get_name(__tileset);
        var _path = global.__bulbProjectDirectory + "tilesets/" + _tilesetName + "/" + _tilesetName + ".yy";
        
        if (!file_exists(_path))
        {
            __BulbError("Could not find \"", _path, "\"\nTileset was ", _tilesetName, " (index ", __tileset, ")");
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