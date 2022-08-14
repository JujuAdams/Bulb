var _t = get_timer();

lighting.StartDrawingToNormalMapFromCamera(camera, true);

var _cameraL = camera_get_view_x(camera);
var _cameraT = camera_get_view_y(camera);

//draw_sprite_tiled() is busted so we have to do this shit ourselves
var _width  = sprite_get_width( sFloorTileNormal);
var _height = sprite_get_height(sFloorTileNormal);

var _y = _height*floor(_cameraT / _height);
repeat(ceil(surface_get_width(application_surface) / _width)+2)
{
    var _x = _width*floor(_cameraL / _width);
    repeat(ceil(surface_get_width(application_surface) / _height)+2)
    {
        BulbDrawNormal(sFloorTileNormal, 0, _x, _y);
        _x += _width;
    }
    
    _y += _height;
}

with(oStaticOccluder)
{
    BulbDrawNormal(sBlockNormal);
}

with(oDynamicOccluder)
{
    BulbDrawNormal(sBlockNormal);
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

drawEndTime = get_timer() - _t;