sunlight = new BulbSunlight(oRendererPar.renderer, 45);
sunlight.blend = c_red;
sunlight.intensity = 1;
sunlight.penumbraSize = 5;

//Turn on normal maps for this light
//This would typically be done using the `BULB_DEFAULT_USE_NORMAL_MAP`
sunlight.normalMap = true;