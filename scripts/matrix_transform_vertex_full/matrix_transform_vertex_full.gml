/// @param matrix
/// @param x
/// @param y
/// @param z
/// @param w
function matrix_transform_vertex_full(argument0, argument1, argument2, argument3, argument4) {

    var _matrix = argument0;
    var _x_in   = argument1;
    var _y_in   = argument2;
    var _z_in   = argument3;
    var _w_in   = argument4;

    var _x = _x_in*_matrix[0] + _y_in*_matrix[4] + _z_in*_matrix[ 8] + _w_in*_matrix[12];
    var _y = _x_in*_matrix[1] + _y_in*_matrix[5] + _z_in*_matrix[ 9] + _w_in*_matrix[13];
    var _z = _x_in*_matrix[2] + _y_in*_matrix[6] + _z_in*_matrix[10] + _w_in*_matrix[14];
    var _w = _x_in*_matrix[3] + _y_in*_matrix[7] + _z_in*_matrix[11] + _w_in*_matrix[15];

    _x /= _w;
    _y /= _w;
    _z /= _w;

    return [_x,_y,_z,_w];



}
