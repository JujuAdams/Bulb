var _t = get_timer();

//Update the lighting
lighting.UpdateFromCamera(camera);

//Draw onto the application surface via the camera
lighting.DrawOnCamera(camera);

drawEndTime = get_timer() - _t;