var _t = get_timer();

lighting.UpdateFromCamera(camera);
lighting.DrawOnCamera(camera);

drawEndTime = get_timer() - _t;