//Update the lighting
lighting.UpdateFromCamera(camera);

lighting.NormalSurfaceClear();
lighting.NormalSurfaceStartDraw();
camera_apply(view_get_camera(0));

with(oNormal)
{
    BulbSpriteNormalDrawSelf();
}

lighting.NormalSurfaceEndDraw();