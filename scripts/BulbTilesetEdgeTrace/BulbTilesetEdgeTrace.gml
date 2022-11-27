/// @param tileset
/// @param [alphaThreshold=0]

function BulbTilesetEdgeTrace(_tileset, _alphaThreshold = 1/255)
{
    if ((_alphaThreshold <= 0) || (_alphaThreshold > 1))
    {
        __BulbError("Alpha threshold must be greater than 0.0 and less than or equal to 1.0");
        return;
    }
    
    _alphaThreshold *= 255;
    
    var _tileWidth  = __BulbGetTilesetTileWidth( _tileset);
    var _tileHeight = __BulbGetTilesetTileHeight(_tileset);
    
    var _extTileWidth  = 4 + _tileWidth;
    var _extTileHeight = 4 + _tileHeight;
    
    var _tilesetTexture = tileset_get_texture(_tileset);
    var _tilesetUVs     = tileset_get_uvs(    _tileset);
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
    repeat(__BulbGetTilesetTilesWide(_tileset))
    {
        draw_line(_x, -1, _x, _surfaceHeight);
        draw_line(_x+1, -1, _x+1, _surfaceHeight);
        _x += _extTileWidth;
        draw_line(_x-2, -1, _x-2, _surfaceHeight);
        draw_line(_x-1, -1, _x-1, _surfaceHeight);
    }
    
    var _y = 0;
    repeat(__BulbGetTilesetTilesHigh(_tileset))
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
    
    var _loopArray = __BulbTraceBuffer(_buffer, _surfaceWidth, _surfaceHeight, 0, 0, 0, false, _alphaThreshold, false);
    
    buffer_delete(_buffer);
    
    var _i = 0;
    repeat(array_length(_loopArray))
    {
        var _loop = _loopArray[_i];
        
        //Figure out which tile this is for using the first point
        var _tileX = _loop[0] div _extTileWidth;
        var _tileY = _loop[1] div _extTileHeight;
        var _tile = BulbDefineTile(_tileset, _tileX, _tileY);
        
        //Adjust the position of all points in the loop relative to the top-left corner of the tile
        var _x = 2 + _tileX*_extTileWidth;
        var _y = 2 + _tileY*_extTileHeight;
        
        var _x1 = undefined;
        var _y1 = undefined;
        var _x2 = _loop[0] - _x;
        var _y2 = _loop[1] - _y;
        
        var _j = 2;
        repeat((array_length(_loop) div 2)-1)
        {
            _x1 = _x2;
            _y1 = _y2;
            _x2 = _loop[_j  ] - _x;
            _y2 = _loop[_j+1] - _y;
            
            if (((_x1 <= 0) && (_x2 <= 0))
            ||  ((_y1 <= 0) && (_y2 <= 0))
            ||  ((_x1 >= _tileWidth) && (_x2 >= _tileWidth))
            ||  ((_y1 >= _tileHeight) && (_y2 >= _tileHeight)))
            {
                
            }
            else
            {
                _tile.AddEdge(_x1, _y1, _x2, _y2);
            }
            
            _j += 2;
        }
        
        ++_i;
    }
}