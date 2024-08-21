//Update the lighting
lighting.UpdateFromCamera(camera);

lighting.NormalSurfaceClear();
lighting.NormalSurfaceStartDraw();
BulbSpriteNormalDrawExt(sNormalMap, 0,  260, 360, 2, 2, 0);
BulbSpriteNormalDrawExt(sNormalMap, 0,  640, 360, -0.9, -0.9, -current_time/50);
lighting.NormalSurfaceEndDraw();