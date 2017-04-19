#define tile_normals
///tile_normals(normTileDepthBegin,normTileDepthEnd)
var ainst, binst;
ainst = instance_create(0,0,tilesConStart);
ainst.depth = argument0+1;
ainst.firstLayer = argument0;
ainst.lastLayer = argument1;
binst = instance_create(0,0,tilesConEnd);
binst.depth = argument1-1;
binst.firstLayer = argument0;
binst.lastLayer = argument1;
ainst.endid = binst;
binst.startid = ainst;

var i;
for(i=0;i<=argument0-argument1;i+=1){
    tile_layer_hide(argument0-i);
}

#define draw_tile_normals_begin
draw_normals_begin();
var i;
/*for(i=0;i<=firstLayer-lastLayer;i+=1){
    tile_layer_shift(firstLayer-i,-view_xview[0],-view_yview[0]);
}
vx = view_xview[0];
vy = view_yview[0];
view_xview[0]=0;
view_yview[0]=0;*/

for(i=0;i<=firstLayer-lastLayer;i+=1){
    
    draw_tiles(firstLayer-i,view_xview[0],view_yview[0],view_wview[0],view_hview[0]);
}

#define draw_tile_normals_end
draw_lighting_complete();
/*view_xview[0]=startid.vx;
view_yview[0]=startid.vy;
var i;
for(i=0;i<=firstLayer-lastLayer;i+=1){
    tile_layer_shift(firstLayer-i,view_xview[0],view_yview[0]);
}*/

#define draw_tiles
///draw_tiles(depth,x,y,w,h,offset)
var _depth, _x, _y, _w, _h, _offset, i, j, curTile;
_depth = argument[0];
_x = argument[1];
_y = argument[2];
_w = argument[3];
_h = argument[4];
_offset = 32;
if(argument_count > 5){ _offset = argument[5]; }

/*tileX = _x mod _offset;
tileY = _y mod _offset;*/

for( i=0; i<ceil(_w/_offset); i+=1 ){
    for( j=0; j<ceil(_h/_offset); j+=1 ){
    
        curTile = tile_layer_find(_depth,_x+(i*_offset),_y+(j*_offset));
        if(curTile = -1 ){ continue; }
        draw_background_part( tile_get_background(curTile), 
            tile_get_left(curTile), tile_get_top(curTile),
            tile_get_width(curTile), tile_get_height(curTile),
            tile_get_x(curTile)-_x, tile_get_y(curTile)-_y);
    
    }
}
 