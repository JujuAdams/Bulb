var _t = get_timer();

lighting.update_from_camera(camera);
lighting.draw(camera_get_view_x(camera), camera_get_view_y(camera));

draw_end_time = get_timer() - _t;