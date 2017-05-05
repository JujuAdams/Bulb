///Create

mask_index = sprite_index;
sprite_index = spr_light_torch;
//Call default light behaviour *after* setting the sprite
event_inherited();

image_yscale = 0.5;
image_blend = make_colour_rgb( 255, 255, 100 );
destroying = false;