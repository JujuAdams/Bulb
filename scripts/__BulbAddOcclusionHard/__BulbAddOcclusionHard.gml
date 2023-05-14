function __BulbAddOcclusionHard(_vbuff)
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
    repeat(array_length(_vertexArray) div 6)
    {
        //Collect first coordinate pair
        var _oldAx = _vertexArray[_i++];
        var _oldAy = _vertexArray[_i++];
        var _oldBx = _vertexArray[_i++];
        var _oldBy = _vertexArray[_i++];
        var _oldDx = _vertexArray[_i++];
        var _oldDy = _vertexArray[_i++];
        
        //...and transform
        var _newAx = x + _oldAx*_xCos + _oldAy*_ySin;
        var _newAy = y - _oldAx*_xSin + _oldAy*_yCos;
        var _newBx = x + _oldBx*_xCos + _oldBy*_ySin;
        var _newBy = y - _oldBx*_xSin + _oldBy*_yCos;
        var _newDx =     _oldDx*_xCos + _oldDy*_ySin;
        var _newDy =   - _oldDx*_xSin + _oldDy*_yCos;
        
        //Add to the vertex buffer
        vertex_position_3d(_vbuff,   _newAx, _newAy, 0);           vertex_normal(_vbuff,   _newDx, _newDy, 0);
        vertex_position_3d(_vbuff,   _newBx, _newBy, __BULB_ZFAR); vertex_normal(_vbuff,   _newDx, _newDy, 0);
        vertex_position_3d(_vbuff,   _newBx, _newBy, 0);           vertex_normal(_vbuff,   _newDx, _newDy, 0);
        
        vertex_position_3d(_vbuff,   _newAx, _newAy, 0);           vertex_normal(_vbuff,   _newDx, _newDy, 0);
        vertex_position_3d(_vbuff,   _newAx, _newAy, __BULB_ZFAR); vertex_normal(_vbuff,   _newDx, _newDy, 0);
        vertex_position_3d(_vbuff,   _newBx, _newBy, __BULB_ZFAR); vertex_normal(_vbuff,   _newDx, _newDy, 0);
    }
}