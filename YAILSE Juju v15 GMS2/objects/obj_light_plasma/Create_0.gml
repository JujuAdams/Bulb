mask_index = sprite_index;
sprite_index = spr_light_small;
//Call default light behaviour *after* setting the sprite
event_inherited();

image_blend = make_colour_hsv( random_range( 70, 90 ), 230, 230 );
destroying = false;