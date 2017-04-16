///Draw

//Draw the walls as one big batch
vertex_submit( vbf_static_block, pr_trianglelist, sprite_get_texture( spr_static_block, 0 ) );

//Draw the player
draw_sprite( sprite_index, image_index, x, y );