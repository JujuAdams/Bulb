var _t = get_timer();

lighting.StartDrawingToNormalMapFromCamera(camera, true);

with(oStaticOccluder)
{
    BulbDrawNormal(sBlockNormal, undefined,
                   640 + x - oPlayer.x, 360 + y - oPlayer.y);
}

with(oDynamicOccluder)
{
    BulbDrawNormal(sBlockNormal, undefined,
                   640 + x - oPlayer.x, 360 + y - oPlayer.y);
}

lighting.StopDrawingToNormalMap();

lighting.UpdateFromCamera(camera);
lighting.DrawOnCamera(camera);

drawEndTime = get_timer() - _t;