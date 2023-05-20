destroying = false;

light = new BulbPointLight(oRenderer.lighting, sLight128, 0, x, y);
light.blend = make_colour_hsv(random_range(70, 90), 230, 230);
light.penumbraSize = 30;