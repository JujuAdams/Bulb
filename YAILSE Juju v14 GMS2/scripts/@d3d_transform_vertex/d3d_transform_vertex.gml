/// @description d3d - Sets the transformation to a scaling with the indicated amounts.
/// @param xs the x scale amount
/// @param ys the y scale amount
/// @param zs the z scale amount
var m = matrix_get( matrix_world );
return matrix_transform_vertex( m, argument0, argument1, argument2 );