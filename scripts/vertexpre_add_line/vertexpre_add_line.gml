/// @param vertexBuffer
/// @param x0
/// @param y0
/// @param x1
/// @param y1
/// @param subdivisions

var _vbuff        = argument0;
var _x0           = argument1;
var _y0           = argument2;
var _x1           = argument3;
var _y1           = argument4;
var _subdivisions = argument5;

if ( _subdivisions <= 0 )
{
    vertex_position_3d( _vbuff,   _x0, _y0, 0 ); vertex_colour( _vbuff, c_white, 1 );
    vertex_position_3d( _vbuff,   _x1, _y1, 0 ); vertex_colour( _vbuff, c_white, 1 );
    exit;
}

_subdivisions = floor( _subdivisions )+1;

var _dx = (_x1 - _x0) / _subdivisions;
var _dy = (_y1 - _y0) / _subdivisions;

var _xb = _x0;
var _yb = _y0;
var _colour = c_lime;
for( var _t = 0; _t <= _subdivisions; _t++ )
{
    var _xa = _xb;
    var _ya = _yb;
    _xb = _x0 + _t*_dx;
    _yb = _y0 + _t*_dy;
    
    vertex_position_3d( _vbuff,   _xa, _ya, 0 ); vertex_colour( _vbuff, _colour, 1 );
    vertex_position_3d( _vbuff,   _xb, _yb, 0 ); vertex_colour( _vbuff, _colour, 1 );
    
    _colour = (_colour == c_lime)? c_red : c_lime;
}