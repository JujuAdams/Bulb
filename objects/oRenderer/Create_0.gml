//Create a camera
view_enabled = true;
view_set_visible(0, true);
camera = camera_create_view(x - 640, y - 360,   1280, 720, 0,   noone, 0, 0, 0, 0);
view_set_camera(0, camera);

ldrAmbientColor = make_colour_rgb(50, 50, 80);
hdrAmbientColor = make_colour_rgb(7, 7, 20);

//Start the lighting system
lighting = new BulbRenderer();
lighting.ambientColor = hdrAmbientColor;
lighting.selfLighting = true;
lighting.soft = false;
lighting.smooth = true;
lighting.hdr = true;
lighting.hdrExposure = 2;
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

application_surface_draw_enable(false);