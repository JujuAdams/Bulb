///Step

blend_cycle = ( blend_cycle + blend_cycle_speed ) mod 255;
image_blend = make_colour_hsv( blend_cycle, 230, 230 );

event_inherited();

