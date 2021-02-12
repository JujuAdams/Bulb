light = bulb_create_light(obj_player.lighting, spr_light_128, 0, x, y);
light.blend = make_colour_hsv(random_range(70, 90), 230, 230);

destroying = false;