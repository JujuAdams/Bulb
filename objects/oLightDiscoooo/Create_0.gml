blendCycleSpeed = random_range(0.1, 1);
blendCycle = random(255);

speed = random_range(0.8, 0.9);
direction = random(360);

light = BulbCreateLight(oRenderer.lighting, sLight512, 0, x, y);
light.penumbraSize = 30;
light.blend = make_colour_hsv(blendCycle, 230, 230);