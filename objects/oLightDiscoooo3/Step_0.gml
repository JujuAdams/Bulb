blendCycle = (blendCycle + blendCycleSpeed) mod 255;

light.x = x;
light.y = y;
light.blend = make_colour_hsv(blendCycle, 230, 230);