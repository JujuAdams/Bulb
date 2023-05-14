function __BulbAddOcclusionSoft(_vbuff)
{
    //Set up basic transforms to turn relative coordinates in arr_shadowGeometry[] into world-space coordinates
    var _sin = dsin(angle);
    var _cos = dcos(angle);
    
    var _xSin = xscale*_sin;
    var _xCos = xscale*_cos;
    var _ySin = yscale*_sin;
    var _yCos = yscale*_cos;
    
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
        vertex_position_3d(_vbuff,   _newAx, _newAy,  0);           vertex_texcoord(_vbuff,  1, 1);
        vertex_position_3d(_vbuff,   _newBx, _newBy,  __BULB_ZFAR); vertex_texcoord(_vbuff,  1, 1);
        vertex_position_3d(_vbuff,   _newBx, _newBy,  0);           vertex_texcoord(_vbuff,  1, 1);
        
        vertex_position_3d(_vbuff,   _newAx, _newAy,  0);           vertex_texcoord(_vbuff,  1, 1);
        vertex_position_3d(_vbuff,   _newAx, _newAy,  __BULB_ZFAR); vertex_texcoord(_vbuff,  1, 1);
        vertex_position_3d(_vbuff,   _newBx, _newBy,  __BULB_ZFAR); vertex_texcoord(_vbuff,  1, 1);
        
        //Add data for the soft shadows
        vertex_position_3d(_vbuff,   _newAx, _newAy,  __BULB_ZFAR); vertex_texcoord(_vbuff,  1, 0);
        vertex_position_3d(_vbuff,   _newAx, _newAy,  0);           vertex_texcoord(_vbuff,  0, 1);
        vertex_position_3d(_vbuff,   _newAx, _newAy,  __BULB_ZFAR); vertex_texcoord(_vbuff,  0, 0);
        
        vertex_position_3d(_vbuff,   _newAx, _newAy, -__BULB_ZFAR); vertex_texcoord(_vbuff,  0, 0); //Bit of a hack. We interpret this in __shdBulbSoftShadows
        vertex_position_3d(_vbuff,   _newAx, _newAy,  0);           vertex_texcoord(_vbuff,  0, 1);
        vertex_position_3d(_vbuff,   _newAx, _newAy,  __BULB_ZFAR); vertex_texcoord(_vbuff,  1, 0);
        
        _i += 6;
    }
}