blendCycleSpeed = random_range(0.1, 1);
blendCycle = random(255);

light = new BulbLight(oRenderer6.lighting, sLight512, 0, x, y, -80);
light.penumbraSize = 30;
light.blend = make_colour_hsv(blendCycle, 230, 230);