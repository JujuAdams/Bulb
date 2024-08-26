//Update the lighting
lighting.UpdateFromCamera(camera);

if (lighting.normalMap)
{
    surface_set_target(lighting.GetNormalMapSurface());
    camera_apply(view_get_camera(0));
    
    BulbNormalMapClear();
    BulbNormalMapShaderSet(false);
    
    draw_sprite_tiled(sFloorNormal, 0, 0, 0);
    
    with(oPyramid)
    {
        BulbNormalMapDrawSelf(sPyramidNormal);
    }
    
    BulbNormalMapShaderSet(true);
    
    staticBlocks.Draw();
    
    with(oDynamicOccluder)
    {
        BulbNormalMapDrawSelf();
    }
    
    surface_reset_target()
    BulbNormalMapShaderReset();
}