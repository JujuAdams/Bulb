/// @param buffer
/// @param bufferWidth
/// @param bufferHeight
/// @param bufferBorder
/// @param xOffset
/// @param yOffset
/// @param forceSinglePass
/// @param buildEdgesInHoles
/// @param [epsilon=1]

function __BulbTraceBufferToEdgeArray(_buffer, _bufferWidth, _bufferHeight, _bufferBorder, _xOffset, _yOffset, _forceSinglePass, _buildEdgesInHoles, _epsilon = 1)
{
    var _alphaThreshold = clamp(255*BULB_TRACE_ALPHA_THRESHOLD, 1, 255);
    
    var _output = [];
    var _loop   = [];
    
    var _spriteWidth  = _bufferWidth  - _bufferBorder;
    var _spriteHeight = _bufferHeight - _bufferBorder;
    var _rowSize      = 4*_bufferWidth;
    
    var _visitedGrid = ds_grid_create(_bufferWidth, _bufferHeight);
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
        
        while(_searchY < _spriteHeight)
        {
            while(_searchX < _spriteWidth)
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
                else if (_buildEdgesInHoles || ((_visitedGrid[# _searchX-1, _searchY] & 0x01) > 0))
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
        array_resize(_loop, 0);
        
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
                        array_push(_loop, _pixelX+1 + _xOffset, _pixelY + _yOffset);
                        
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
                        array_push(_loop, _pixelX+1 + _xOffset, _pixelY + _yOffset);
                        
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
                        array_push(_loop, _pixelX + _xOffset, _pixelY + _yOffset);
                        
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
                        array_push(_loop, _pixelX + _xOffset, _pixelY + _yOffset);
                        
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
                        array_push(_loop, _pixelX + _xOffset, _pixelY+1 + _yOffset);
                        
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
                        array_push(_loop, _pixelX + _xOffset, _pixelY+1 + _yOffset);
                        
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
                        array_push(_loop, _pixelX+1 + _xOffset, _pixelY+1 + _yOffset);
                        
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
                        array_push(_loop, _pixelX+1 + _xOffset, _pixelY+1 + _yOffset);
                        
                        //We're an outside corner, rotate clockwise
                        _direction = 0x04;
                    }
                break;
            }
        }
        
        //Close the loop
        array_push(_loop, _loop[0], _loop[1]);
        
        __BulbAddImageToOccluderInternal(_output, _loop, 0, array_length(_loop)-2, _epsilon);
        
        if (_forceSinglePass) break;
    }
    
    ds_grid_destroy(_visitedGrid);
    
    return {
        __edgeArray: _output,
        __radius:    0,
    };
}

function __BulbAddImageToOccluderInternal(_occluderVertexArray, _pointArray, _start, _end, _epsilon = 1)
{
    var _maxDist = 0;
    
    var _x1 = _pointArray[_start  ];
    var _y1 = _pointArray[_start+1];
    var _x2 = _pointArray[_end    ];
    var _y2 = _pointArray[_end+1  ];
    
    var _dx = _x2 - _x1;
    var _dy = _y2 - _y1;
    
    if (_end - _start >= 4)
    {
        var _lengthSquared = _dx*_dx + _dy*_dy;
        
        if (_lengthSquared == 0)
        {
            var _maxDist  = 0;
            var _maxPoint = undefined;
            var _p = _start+2;
            repeat(((_end - _start) div 2) - 1)
            {
                var _x = _pointArray[_p  ];
                var _y = _pointArray[_p+1];
                
                var _distance = point_distance(_x1, _y1, _x, _y);
                if (_distance >= _maxDist)
                {
                    _maxDist  = _distance;
                    _maxPoint = _p;
                }
                
                _p += 2;
            }
        }
        else
        {
            var _maxPoint = undefined;
            var _p = _start+2;
            repeat(((_end - _start) div 2) - 1)
            {
                var _x = _pointArray[_p  ];
                var _y = _pointArray[_p+1];
                
                var _t = real((_x - _x1)*_dx + (_y - _y1)*_dy) / _lengthSquared;
                _t = clamp(_t, 0, 1);
                
                var _xP = _x1 + _t*_dx;
                var _yP = _y1 + _t*_dy;
                
                var _perpendicularDistance = point_distance(_x, _y, _xP, _yP);
                if (_perpendicularDistance >= _maxDist)
                {
                    _maxDist  = _perpendicularDistance;
                    _maxPoint = _p;
                }
                
                _p += 2;
            }
        }
        
        if (_maxDist >= _epsilon)
        {
            __BulbAddImageToOccluderInternal(_occluderVertexArray, _pointArray, _start, _maxPoint, _epsilon);
            __BulbAddImageToOccluderInternal(_occluderVertexArray, _pointArray, _maxPoint, _end, _epsilon);
        }
    }
    
    if (_maxDist < _epsilon)
    {
        var _x3 = undefined;
        var _y3 = undefined;
        var _x4 = _pointArray[_start  ];
        var _y4 = _pointArray[_start+1];
        
        var _p = _start + 2;
        repeat((_end - _start) div 2)
        {
            _x3 = _x4;
            _y3 = _y4;
            var _x4 = _pointArray[_p  ];
            var _y4 = _pointArray[_p+1];
            
            array_push(_occluderVertexArray, _x3, _y3,
                                             _x4, _y4,
                                             _x1, _y1,
                                             _x2, _y2);
            
            _p += 2;
        }
    }
}