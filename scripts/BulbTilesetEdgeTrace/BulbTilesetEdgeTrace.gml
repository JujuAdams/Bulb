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
    var _bufferSize = 4*_surfaceWidth*_surfaceHeight;
    var _rowSize    = 4*_surfaceWidth;
    
    var _buffer = buffer_create(_bufferSize, buffer_fixed, 1);
    buffer_get_surface(_buffer, _surface, 0);
    buffer_seek(_buffer, buffer_seek_start, 0);
    surface_free(_surface);
    
    var _loopArray = [];
    var _visitedGrid = ds_grid_create(_surfaceWidth, _surfaceHeight);
    // 0x00 = Unvisited
    // 0x01 = Visited right edge
    // 0x02 = Visited top edge
    // 0x04 = Visited left edge
    // 0x08 = Visited bottom edge
    
    var _searchX = 1;
    var _searchY = 1;
    var _inside  = false;
    
    while(true)
    {
        //Find the next point of contact
        var _found = false;
        
        while(_searchY < _surfaceHeight)
        {
            while(_searchX < _surfaceWidth)
            {
                //Last byte in every 32-bit value is alpha (due to GM's native ABGR layout)
                if (buffer_peek(_buffer, _searchY*_rowSize + 4*_searchX + 3, buffer_u8) >= _alphaThreshold) //Alpha is greater than the threshold
                {
                    if (!_inside)
                    {
                        _inside = true;
                        
                        if ((_visitedGrid[# _searchX, _searchY] & 0x04) > 0)
                        {
                            //If we've already visited the left-hand side of this pixel then we've already handled this pixel on a prior loop
                        }
                        else
                        {
                            _found = true;
                            break;
                        }
                    }
                }
                else if ((_visitedGrid[# _searchX-1, _searchY] & 0x01) > 0)
                {
                    //We're outside!
                    _inside = false;
                }
                
                ++_searchX;
            }
        
            if (_found) break;
            
            _searchX = 1;
            ++_searchY;
        }
        
        if (!_found)
        {
            //No more pixels to traverse
            break;
        }
        
        var _pixelX = _searchX;
        var _pixelY = _searchY;
        
        //Start a new loop
        var _loop = [];
        array_push(_loopArray, _loop);
        
        //We traverse the edge of the sprite clockwise
        // 0x01 = Heading right, checking edge is above us
        // 0x02 = Heading up, checking edge is to the left of us
        // 0x04 = Heading left, checking edge is below us
        // 0x08 = Heading down, checking edge is to the right of us
        //Since we just discovered
        var _direction = 0x02;
        
        var _open = true;
        while(_open)
        {
            //Last byte in every 32-bit value is alpha (due to GM's native ABGR layout)
            var _bufferPos = _pixelY*_rowSize + 4*_pixelX + 3;
            switch(_direction)
            {
                case 0x01: //Right
                    //If we've already hit this edge then we've closed a loop and can stop
                    if ((_visitedGrid[# _pixelX, _pixelY] & 0x02) > 0)
                    {
                        _open = false;
                        break;
                    }
                    
                    _visitedGrid[# _pixelX, _pixelY] |= 0x02;
                    
                    if (buffer_peek(_buffer, _bufferPos - _rowSize + 4, buffer_u8) >= _alphaThreshold)
                    {
                        //There's a pixel to our top-right but no pixel directly to our right
                        array_push(_loop, _pixelX+1, _pixelY);
                        
                        ++_pixelX;
                        --_pixelY;
                        
                        //We're an inside corner, rotate counterclockwise
                        _direction = 0x02;
                    }
                    else if (buffer_peek(_buffer, _bufferPos + 4, buffer_u8) >= _alphaThreshold)
                    {
                        //There's a pixel to the right of us
                        ++_pixelX;
                    }
                    else
                    {
                        array_push(_loop, _pixelX+1, _pixelY);
                        
                        //We're an outside corner, rotate clockwise
                        _direction = 0x08;
                    }
                break;
                
                
                
                case 0x02: //Up
                    //If we've already hit this edge then we've closed a loop and can stop
                    if ((_visitedGrid[# _pixelX, _pixelY] & 0x04) > 0)
                    {
                        _open = false;
                        break;
                    }
                    
                    _visitedGrid[# _pixelX, _pixelY] |= 0x04;
                    
                    if (buffer_peek(_buffer, _bufferPos - _rowSize - 4, buffer_u8) >= _alphaThreshold)
                    {
                        //There's a pixel to our top-left
                        array_push(_loop, _pixelX, _pixelY);
                        
                        --_pixelX;
                        --_pixelY;
                        
                        //We're an inside corner, rotate counterclockwise
                        _direction = 0x04;
                    }
                    else if (buffer_peek(_buffer, _bufferPos - _rowSize, buffer_u8) >= _alphaThreshold)
                    {
                        //There's a pixel above us
                        --_pixelY;
                    }
                    else
                    {
                        array_push(_loop, _pixelX, _pixelY);
                        
                        //We're an outside corner, rotate clockwise
                        _direction = 0x01;
                    }
                break;
                
                
                
                case 0x04: //Left
                    //If we've already hit this edge then we've closed a loop and can stop
                    if ((_visitedGrid[# _pixelX, _pixelY] & 0x08) > 0)
                    {
                        _open = false;
                        break;
                    }
                    
                    _visitedGrid[# _pixelX, _pixelY] |= 0x08;
                    
                    if (buffer_peek(_buffer, _bufferPos + _rowSize - 4, buffer_u8) >= _alphaThreshold)
                    {
                        //There's a pixel to our bottom-left
                        array_push(_loop, _pixelX, _pixelY+1);
                        
                        --_pixelX;
                        ++_pixelY;
                        
                        //We're an inside corner, rotate counterclockwise
                        _direction = 0x08;
                    }
                    else if (buffer_peek(_buffer, _bufferPos - 4, buffer_u8) >= _alphaThreshold)
                    {
                        //There's a pixel to the left of us
                        --_pixelX;
                    }
                    else
                    {
                        array_push(_loop, _pixelX, _pixelY+1);
                        
                        //We're an outside corner, rotate clockwise
                        _direction = 0x02;
                    }
                break;
                
                
                
                case 0x08: //Down
                    //If we've already hit this edge then we've closed a loop and can stop
                    if ((_visitedGrid[# _pixelX, _pixelY] & 0x01) > 0)
                    {
                        _open = false;
                        break;
                    }
                    
                    _visitedGrid[# _pixelX, _pixelY] |= 0x01;
                    
                    if (buffer_peek(_buffer, _bufferPos + _rowSize + 4, buffer_u8) >= _alphaThreshold)
                    {
                        //There's a pixel to our bottom-right
                        array_push(_loop, _pixelX+1, _pixelY+1);
                        
                        ++_pixelX;
                        ++_pixelY;
                        
                        //We're an inside corner, rotate counterclockwise
                        _direction = 0x01;
                    }
                    else if (buffer_peek(_buffer, _bufferPos + _rowSize, buffer_u8) >= _alphaThreshold)
                    {
                        //There's a pixel below us
                        ++_pixelY;
                    }
                    else
                    {
                        array_push(_loop, _pixelX+1, _pixelY+1);
                        
                        //We're an outside corner, rotate clockwise
                        _direction = 0x04;
                    }
                break;
            }
        }
        
        //Close the loop
        array_push(_loop, _loop[0], _loop[1]);
    }
    
    ds_grid_destroy(_visitedGrid);
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