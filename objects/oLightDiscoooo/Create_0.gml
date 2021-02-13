blend_cycle_speed = random_range(0.1, 1);
blend_cycle = random(255);

speed = random_range(0.8, 0.9);
direction = random(360);

light = BulbCreateLight(oRenderer.lighting, sLight512, 0, x, y);
light.penumbra_size = 30;
light.blend = make_colour_hsv(blend_cycle, 230, 230);