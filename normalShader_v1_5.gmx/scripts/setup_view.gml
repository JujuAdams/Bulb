var ratio;
application_surface_enable(false);
ratio = window_get_width() / window_get_height();
view_hview[0] = 400;
view_wview[0] = 400*ratio;
view_wport[0] = window_get_width();
view_hport[0] = window_get_height();
