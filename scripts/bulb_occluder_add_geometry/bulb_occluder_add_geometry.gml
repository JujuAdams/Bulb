/// Tool to quickly fill a squential array of lines
///
/// @param x1
/// @param y1
/// @param x2
/// @param y2

function bulb_occluder_add_geometry(_x1, _y1, _x2, _y2)
{
    var _size = 4*__bulb_vertex_count;
    array_resize(__bulb_vertex_array, _size + 4);
    
    __bulb_vertex_array[@ _size    ] = _x1;
    __bulb_vertex_array[@ _size + 1] = _y1;
    __bulb_vertex_array[@ _size + 2] = _x2;
    __bulb_vertex_array[@ _size + 3] = _y2;
    
    __bulb_vertex_count++;
}