var _t = get_timer();

lighting.UpdateFromCamera(camera);
lighting.Draw(camera_get_view_x(camera), camera_get_view_y(camera));

drawEndTime = get_timer() - _t;