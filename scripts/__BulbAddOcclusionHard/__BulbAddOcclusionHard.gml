function __BulbAddOcclusionHard(_vbuff)
{
    //Set up basic transforms to turn relative coordinates in arr_shadowGeometry[] into world-space coordinates
    var _sin = dsin(angle);
    var _cos = dcos(angle);
    
    var _xSin = xscale*_sin;
    var _xCos = xscale*_cos;
    var _ySin = yscale*_sin;
    var _yCos = yscale*_cos;
    
    if ((xscale < 0) ^^ (yscale < 0)) //If we have one negative scaling dimension...
    {
        //Loop through every line segment, remembering that we're storing coordinate data sequentially: { Ax1, Ay1, Bx1, Bx1,   Ax2, Ay2, Bx2, Bx2, ... }
        var _vertexArray = vertexArray;
        var _i = 0;
        repeat(array_length(_vertexArray) div __BULB_ARRAY_VERTEX_SIZE)
        {
            //Collect first coordinate pair
            var _oldAx = _vertexArray[_i  ];
            var _oldAy = _vertexArray[_i+1];
            var _oldBx = _vertexArray[_i+2];
            var _oldBy = _vertexArray[_i+3];
            
            //...and transform
            var _newAx = x + _oldAx*_xCos + _oldAy*_ySin;
            var _newAy = y - _oldAx*_xSin + _oldAy*_yCos;
            var _newBx = x + _oldBx*_xCos + _oldBy*_ySin;
            var _newBy = y - _oldBx*_xSin + _oldBy*_yCos;
            
            //Add to the vertex buffer
            //Note that we reverse the winding order relative to below because we have one negative scaling dimension
            vertex_position_3d(_vbuff,   _newAx, _newAy,  0);           vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _newBx, _newBy,  0);           vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _newBx, _newBy,  __BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
            
            vertex_position_3d(_vbuff,   _newAx, _newAy,  0);           vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _newBx, _newBy,  __BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _newAx, _newAy,  __BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
            
            _i += __BULB_ARRAY_VERTEX_SIZE;
        }
    }
    else
    {
        //Loop through every line segment, remembering that we're storing coordinate data sequentially: { Ax1, Ay1, Bx1, Bx1,   Ax2, Ay2, Bx2, Bx2, ... }
        var _vertexArray = vertexArray;
        var _i = 0;
        repeat(array_length(_vertexArray) div __BULB_ARRAY_VERTEX_SIZE)
        {
            //Collect first coordinate pair
            var _oldAx = _vertexArray[_i  ];
            var _oldAy = _vertexArray[_i+1];
            var _oldBx = _vertexArray[_i+2];
            var _oldBy = _vertexArray[_i+3];
            
            //...and transform
            var _newAx = x + _oldAx*_xCos + _oldAy*_ySin;
            var _newAy = y - _oldAx*_xSin + _oldAy*_yCos;
            var _newBx = x + _oldBx*_xCos + _oldBy*_ySin;
            var _newBy = y - _oldBx*_xSin + _oldBy*_yCos;
            
            //Add to the vertex buffer
            vertex_position_3d(_vbuff,   _newAx, _newAy,  0);           vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _newBx, _newBy,  __BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _newBx, _newBy,  0);           vertex_colour(_vbuff,   c_black, 1);
            
            vertex_position_3d(_vbuff,   _newAx, _newAy,  0);           vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _newAx, _newAy,  __BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
            vertex_position_3d(_vbuff,   _newBx, _newBy,  __BULB_ZFAR); vertex_colour(_vbuff,   c_black, 1);
            
            _i += __BULB_ARRAY_VERTEX_SIZE;
        }
    }
}