var _t = get_timer();

vision.UpdateFromCamera(camera);

surface_set_target(vision.GetSurface());
gpu_set_colorwriteenable(false, false, false, true);
draw_rectangle(0, 0, 1280, 720, false);
gpu_set_colorwriteenable(true, true, true, true);
surface_reset_target();

surface_copy(lighting.GetClippingSurface(), 0, 0, vision.GetSurface());

lighting.UpdateFromCamera(camera);
lighting.DrawOnCamera(camera);

drawEndTime = get_timer() - _t;