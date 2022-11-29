lighting.StartDrawingToNormalMapFromCamera(camera, true);

var _tilemap = layer_tilemap_get_id("Tiles3");
var _tileWidth  = tilemap_get_tile_width( _tilemap);
var _tileHeight = tilemap_get_tile_height(_tilemap);

var _y = 0;
repeat(tilemap_get_height(_tilemap))
{
    var _x = 0;
    repeat(tilemap_get_width(_tilemap))
    {
        var _tileIndex = tilemap_get(_tilemap, _x, _y) & tile_index_mask;
        if (_tileIndex > 0) draw_tile(tsTileset3Normal, _tileIndex, 0, _tileWidth*_x, _tileHeight*_y);
        ++_x;
    }
    
    ++_y;
}

lighting.StopDrawingToNormalMap();

lighting.UpdateFromCamera(camera);

if (showNormalMap)
{
    var _viewMatrix = camera_get_view_mat(camera);
    var _projMatrix = camera_get_proj_mat(camera);
    
    //Deploy PROPER MATHS in case the dev is using matrices
    var _cameraX          = -_viewMatrix[12];
    var _cameraY          = -_viewMatrix[13];
    var _cameraViewWidth  = round(abs(2/_projMatrix[0]));
    var _cameraViewHeight = round(abs(2/_projMatrix[5]));
    var _cameraLeft       = _cameraX - _cameraViewWidth/2;
    var _cameraTop        = _cameraY - _cameraViewHeight/2;
    
    var _surface = lighting.GetNormalMapSurface();
    draw_surface_stretched_ext(_surface, _cameraLeft, _cameraTop, _cameraViewWidth, _cameraViewHeight, c_white, 1.0);
}
else
{
    lighting.DrawOnCamera(camera);
}