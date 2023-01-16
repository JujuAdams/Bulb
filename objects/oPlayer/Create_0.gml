light = new BulbLight(oRenderer.lighting, sLightTorch, 0, x, y);
light.penumbraSize = 30;
light.yscale = 0.5;
light.blend = make_colour_rgb(255, 255, 100);

visionCone = new BulbLight(oRenderer.vision, sLightTorch, 0, x, y);
visionCone.penumbraSize = 30;
visionCone.xscale = 2;
visionCone.yscale = 2;
visionCone.blend = c_white;