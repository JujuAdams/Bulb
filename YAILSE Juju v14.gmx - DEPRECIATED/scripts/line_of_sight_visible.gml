///line_of_sight_visible( x1, y1, x2, y2, grid, occlusion value )
//  
//  23rd Nov '15
//  eNzy

var x1   = argument0;
var y1   = argument1;
var x2   = argument2;
var y2   = argument3;
var grid = argument4;
var occ  = argument5;

var vx = x2 - x1;
var vy = y2 - y1;
var l  = point_distance( 0, 0,   vx, vy );
if ( l <= 0 ) return true;

vx /= l;
vy /= l;
var ox = x1 + 0.5;
var oy = y1 + 0.5;

repeat( floor( l ) ) {
    if ( ds_grid_get( grid, floor( ox ), floor( oy ) ) == occ ) return false;
    ox += vx;
    oy += vy;
}

return true;
