destroying = false;

light = bulb_create_light(obj_renderer.lighting, spr_light_128, 0, x, y);
light.blend = make_colour_hsv(random_range(70, 90), 230, 230);
light.penumbra_size = 30;