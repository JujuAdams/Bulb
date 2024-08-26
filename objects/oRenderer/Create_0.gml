//Create a camera manually so we don't have to torture ourselves with the room editor
view_enabled = true;
view_set_visible(0, true);
camera = camera_create_view(x - 640, y - 360,   1280, 720, 0,   noone, 0, 0, 0, 0);
view_set_camera(0, camera);

//////////////////////
//                  //
//  Renderer Setup  //
//                  //
//////////////////////

//We'll be drawing the application surface ourselves (see Post-Draw event)
application_surface_draw_enable(false);

//Start the renderer system
renderer = new BulbRenderer();
renderer.SetSurfaceDimensionsFromCamera(camera);

//Set up ambient light. As this is a lighting value, the ambient color is defined in linear color
//space.
renderer.ambientColor = make_colour_rgb(10, 10, 20);

//Use soft shadows
renderer.soft = true;

//Use texture filtering (bilinear interpolation) wherever possible
renderer.smooth = true;

//Turn on normal maps
//This would typically be done using the `BULB_DEFAULT_USE_NORMAL_MAP`
renderer.normalMap = true;

//Set up HDR
renderer.hdr = true;
renderer.hdrBloomIntensity = 0.05;
renderer.hdrBloomIterations = 4;

//Copy the HDR tonemap across to LDR. You normally want to stick to `BULB_TONEMAP_CLAMP` when nont
//in HDR mode. For the sake of example, however, we want the two tonemaps to match.
renderer.ldrTonemap = renderer.hdrTonemap;

////////////////////////////
//                        //
//  Example-related code  //
//                        //
////////////////////////////

//Set up a vertex buffer for drawing the diffuse base texture for the walls
//This isn't strictly part of the renderer example
staticBlocks = new VertexCake();
staticBlocks.Bake(oStaticOccluder, sStaticBlock, 0, true);

//Some debug values
showDebug = false;
smoothedFrameTime = 1;
smoothedFPS = 1000;
alarm_set(0, 30);