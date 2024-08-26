//Create a camera
view_enabled = true;
view_set_visible(0, true);
camera = camera_create_view(x - 640, y - 360,   1280, 720, 0,   noone, 0, 0, 0, 0);
view_set_camera(0, camera);

//We'll be drawing the application surface ourselves (see Post-Draw event)
application_surface_draw_enable(false);

//Start the renderer system
renderer = new BulbRenderer();
renderer.SetSurfaceDimensionsFromCamera(camera);

renderer.ambientColor = make_colour_rgb(50, 50, 80);
renderer.selfLighting = true;
renderer.soft = true;
renderer.smooth = true;

//Turn on normal maps
//This would typically be done using the `BULB_DEFAULT_USE_NORMAL_MAP`
renderer.normalMap = true;

//Set up HDR
renderer.hdr = true;
renderer.hdrAmbientInGammaSpace = true;
renderer.hdrBloomIntensity = 0.05;
renderer.hdrBloomIterations = 4;

//Set up a vertex buffer for drawing the diffuse base texture for the walls
//This isn't strictly part of the renderer example
staticBlocks = new VertexCake();
staticBlocks.Bake(oStaticOccluder, sStaticBlock, 0, true);

//Some debug values
showDebug = false;
drawEndTime = 300;
smoothedDrawEndTime = 300;
smoothedFrameTime = 1;
smoothedFPS = 1000;
alarm_set(0, 30);