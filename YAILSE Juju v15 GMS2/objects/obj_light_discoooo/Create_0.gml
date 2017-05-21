mask_index = sprite_index;
sprite_index = spr_light;

//Call default light behaviour *after* setting the sprite
event_inherited();

//speed = random_range( 3, 6 );
direction = random( 360 );

blend_cycle_speed = random_range( 0.1, 1 );
blend_cycle = random( 255 );
image_blend = make_colour_hsv( blend_cycle, 230, 230 );