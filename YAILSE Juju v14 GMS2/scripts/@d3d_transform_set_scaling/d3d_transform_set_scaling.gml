/// @description d3d - Sets the transformation to a scaling with the indicated amounts.
/// @param xs the x scale amount
/// @param ys the y scale amount
/// @param zs the z scale amount

// build the rotation matrix
var m = matrix_build_identity();
m[0] = argument0;
m[5] = argument1;
m[10] = argument2;
matrix_set( matrix_world, m);
