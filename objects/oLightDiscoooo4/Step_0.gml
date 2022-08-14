blendCycle = (blendCycle + blendCycleSpeed) mod 255;

light.blend = make_colour_hsv(blendCycle, 230, 230);