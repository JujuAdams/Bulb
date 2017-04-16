/// @description d3d - Sets the transformation to a translation over the indicated vector.
/// @param xt x value
/// @param yt y value
/// @param zt z value

// build the rotation matrix
var mT = matrix_build_identity();
mT[12] = argument0;
mT[13] = argument1;
mT[14] = argument2;

var m = matrix_get( matrix_world );
var mR = matrix_multiply( m, mT );
matrix_set( matrix_world, mR );
