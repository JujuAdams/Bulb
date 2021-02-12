blend_cycle = (blend_cycle + blend_cycle_speed) mod 255;

light.x = x;
light.y = y;
light.blend = make_colour_hsv(blend_cycle, 230, 230);