light = bulb_create_light(obj_player.lighting, spr_light_torch, 0, x, y);
light.penumbra_size = 30;
light.yscale = 0.5;
light.blend = make_colour_rgb(255, 255, 100);

destroying = false;