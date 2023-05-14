/// @param spriteEdge
/// @param x
/// @param y
/// @param xScale
/// @param yScale
/// @param rotation

function __BulbLoopDebug(_loopArray, _xOffset, _yOffset, _xScale, _yScale, _rotation)
{
    var _matrix = matrix_build(0,0,0,   0,0,0,   _xScale, _yScale, 1);
    _matrix = matrix_multiply(_matrix, matrix_build(0,0,0,   0,0,_rotation,   1,1,1));
    _matrix = matrix_multiply(_matrix, matrix_build(_xOffset, _yOffset, 0,   0,0,0,   1,1,1));
    matrix_set(matrix_world, _matrix);
    
    var _i = 0;
    repeat(array_length(_loopArray))
    {
        var _loop = _loopArray[_i];
        
        draw_primitive_begin(pr_linestrip);
        
        var _p = 0;
        repeat(array_length(_loop) div 2)
        {
            draw_vertex(_loop[_p], _loop[_p+1]);
            _p += 2;
        }
        
        draw_primitive_end();
        
        ++_i;
    }
    
    matrix_set(matrix_world, matrix_build_identity());
}