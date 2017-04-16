/// @description d3d - Sets the transformation to a scaling with the indicated amounts.
/// @param xs the x scale amount
/// @param ys the y scale amount
/// @param zs the z scale amount

// build the rotation matrix
var mT = matrix_build_identity();
mT[0] = argument0;
mT[5] = argument1;
mT[10] = argument2;
var m = matrix_get( matrix_world );
var mR = matrix_multiply( m, mT );
matrix_set( matrix_world, mR );

