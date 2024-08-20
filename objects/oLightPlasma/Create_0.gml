destroying = false;

light = new BulbLight(oRenderer.lighting, sLight128, 0, x, y);
light.blend = make_colour_hsv(random_range(70, 90), 230, 230);
light.castShadows = true;
light.xscale = 0.3;
light.yscale = 0.3;
light.intensity = 15;