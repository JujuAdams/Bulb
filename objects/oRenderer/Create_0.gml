//Create a camera
view_enabled = true;
view_set_visible(0, true);
camera = camera_create_view(x - 640, y - 360,   1280, 720, 0,   noone, 0, 0, 0, 0);
view_set_camera(0, camera);

//We'll be drawing the application surface ourselves (see Post-Draw event)
application_surface_draw_enable(false);

//Start the lighting system
lighting = new BulbRenderer();
lighting.ambientColor = make_colour_rgb(50, 50, 80);
lighting.selfLighting = true;
lighting.soft = true;
lighting.smooth = true;

lighting.hdr = true;
lighting.hdrAmbientInGammaSpace = true;
lighting.hdrBloomIntensity = 0.2;
lighting.hdrBloomIterations = 3;

lighting.SetSurfaceDimensionsFromCamera(camera);

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
sunlight.intensity = 1;
sunlight.penumbraSize = 5;