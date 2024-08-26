//Update the lighting
lighting.UpdateFromCamera(camera);

if (lighting.normalMap)
{
    surface_set_target(lighting.GetNormalMapSurface());
    BulbNormalMapShaderSet();
    BulbNormalMapClear();
    
    camera_apply(view_get_camera(0));
    
    draw_sprite_tiled(sFloorNormal, 0, 0, 0);
    
    with(oNormal)
    {
        BulbSpriteNormalDrawExt(sPyramidNormal, image_index, x, y, image_xscale, image_yscale, image_angle);
    }
    
    surface_reset_target()
    BulbNormalMapShaderReset();
}