light = bulb_create_light(obj_player.lighting, spr_light_512, 0, x, y);

speed = random_range(0.8, 0.9);
direction = random(360);

blend_cycle_speed = random_range(0.1, 1);
blend_cycle = random(255);
light.blend = make_colour_hsv(blend_cycle, 230, 230);