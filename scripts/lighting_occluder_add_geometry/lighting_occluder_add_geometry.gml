/// Tool to quickly fill a squential array of lines.
///
/// return: Nothing
/// 
/// This code and engine are provided under the Creative Commons "Attribution - NonCommerical - ShareAlike" international license.
/// https://creativecommons.org/licenses/by-nc-sa/4.0/
///
/// @param x1
/// @param y1
/// @param x2
/// @param y2

function lighting_occluder_add_geometry(_x1, _y1, _x2, _y2)
{
    arr_shadow_geometry[shadow_geometry_size] = _x1; shadow_geometry_size++;
    arr_shadow_geometry[shadow_geometry_size] = _y1; shadow_geometry_size++;
    arr_shadow_geometry[shadow_geometry_size] = _x2; shadow_geometry_size++;
    arr_shadow_geometry[shadow_geometry_size] = _y2; shadow_geometry_size++;
    shadow_geometry_count++;
}