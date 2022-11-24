draw_self();

if (keyboard_check(vk_space))
{
    draw_set_colour(c_red);
    BulbSpriteEdgeDebug(loopArray, x, y, image_xscale, image_yscale, image_angle);
    draw_set_colour(c_white);
}