//Create a camera
view_enabled = true;
view_set_visible(0, true);
camera = camera_create_view(x - 640, y - 360,   1280, 720, 0,   noone, 0, 0, 0, 0);
view_set_camera(0, camera);

//Start the lighting system
lighting = new BulbRenderer(make_colour_rgb(50, 50, 80), BULB_MODE.SOFT_BM_ADD, true);
lighting.SetSurfaceDimensionsFromCamera(camera);
lighting.SetClippingSurface(true, 1.0, false, true);

vision = new BulbRenderer(c_black, BULB_MODE.SOFT_BM_ADD, true);

//Set up a vertex buffer for drawing the diffuse base texture for the walls
//This isn't strictly part of the lighting example
staticBlocks = new VertexCake();
staticBlocks.Bake(oStaticOccluder, sStaticBlock, 0, true);

//Some debug values
showDebug = false;
drawEndTime = 300;
smoothedDrawEndTime = 300;
smoothedFrameTime = 1;
smoothedFPS = 1000;
alarm_set(0, 30);

sunlight = new BulbSunlight(lighting, 45);
sunlight.blend = c_red;
sunlight.alpha = 0.4;
sunlight.penumbraSize = 5;

application_surface_draw_enable(false);