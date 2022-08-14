lighting.StartDrawingToNormalMapFromCamera(camera, true);

draw_sprite_tiled(sFloorTileNormal, 0, 0, 0);

with(oStaticOccluder4)
{
    BulbDrawNormal(sBlockNormal);
}

with(oDynamicOccluder4)
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
