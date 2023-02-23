var _t = get_timer();

////Update the vision cone
//vision.UpdateFromCamera(camera);
//
////Copy the vision cone to the lighting clipping surface
//lighting.CopyClippingSurface(vision.GetSurface());

//Update the lighting
lighting.UpdateFromCamera(camera);

//Draw onto the application surface via the camera
lighting.DrawOnCamera(camera);

drawEndTime = get_timer() - _t;