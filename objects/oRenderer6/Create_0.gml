//Create a camera
view_enabled = true;
view_set_visible(0, true);
camera = camera_create_view(x - 640, y - 360,   640, 360, 0,   noone, 0, 0, 0, 0);
view_set_camera(0, camera);

//Start the lighting system
lighting = new BulbRenderer(make_colour_rgb(50, 50, 80), BULB_MODE.SOFT_BM_ADD, false);