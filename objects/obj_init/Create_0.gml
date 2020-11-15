if ((display_get_width() < window_get_width()) || (display_get_height() < window_get_height()))
{
    window_set_fullscreen(true);
}

room_goto_next();