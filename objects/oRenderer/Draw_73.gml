//Update the lighting
lighting.UpdateFromCamera(camera);

lighting.NormalSurfaceClear();
lighting.NormalSurfaceStartDraw();
camera_apply(view_get_camera(0));

draw_sprite_tiled(sFloorNormal, 0, 0, 0);

with(oNormal)
{
    BulbSpriteNormalDrawExt(sPyramidNormal, image_index, x, y, image_xscale, image_yscale, image_angle);
}

lighting.NormalSurfaceEndDraw();