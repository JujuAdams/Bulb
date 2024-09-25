//Update the renderer's normal map
if (renderer.normalMap)
{
    //First we target the normal map surface
    surface_set_target(renderer.GetNormalMapSurface());
    
    //Then we apply the camera. This ensure we're drawing from the same "point of view" as the
    //rest of the renderer
    camera_apply(view_get_camera(0));
    
    //Clear off any normal map information from the previous frame
    BulbNormalMapClear();
    
    //Set the normal mapping shader. This is required if you want to use the `BulbNormalMapDraw*()`
    //functions (which is recommended).
    BulbNormalMapShaderSet();
    
    draw_sprite_tiled(sFloorNormal, 0, 0, 0);
    
    with(oPyramid)
    {
        BulbNormalMapDrawSelf(sPyramidNormal);
    }
    
    //Now we set the normal map shader but this time with `forceUpNormal` set to `true`. This means
    //that anything we draw afterwards will be drawn completely flat.
    BulbNormalMapShaderSet(true);
    
    staticBlocks.Draw();
    
    with(oDynamicOccluder)
    {
        BulbNormalMapDrawSelf();
    }
    
    //Reset the surface target and the shader, and we're done
    surface_reset_target()
    BulbNormalMapShaderReset();
}

//Update the renderer. You should do this after updating the normal map!
renderer.Update();