/// @param vertexBuffer
/// @param x0
/// @param y0
/// @param x1
/// @param y1
/// @param spacing
/// @param colour

var _vbuff   = argument0;
var _x0      = argument1;
var _y0      = argument2;
var _x1      = argument3;
var _y1      = argument4;
var _spacing = argument5;
var _colour  = argument6;

var _dx = _x1 - _x0;
var _dy = _y1 - _y0;

var _incr = _spacing / sqrt( _dx*_dx + _dy*_dy );

for( var _t = 0; _t < 1; _t += _incr )
{
    var _x = _x0 + _t*_dx
    var _y = _y0 + _t*_dy;
    vertex_position_3d( _vbuff,   _x, _y, 0 ); vertex_colour( _vbuff, _colour, 1 );
}

vertex_position_3d( _vbuff,   _x1, _y1, 0 ); vertex_colour( _vbuff, _colour, 1 );