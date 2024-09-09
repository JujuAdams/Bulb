light = new BulbLight(oRendererPar.renderer, sLightTorch, 0, x, y);
light.z = 100;
light.penumbraSize = 30;
light.yscale = 0.5;
light.blend = make_colour_rgb(255, 255, 100);
light.intensity = 1.5;

//Turn on normal maps for this light
//This would typically be done using the `BULB_DEFAULT_USE_NORMAL_MAP`
light.normalMap = true;