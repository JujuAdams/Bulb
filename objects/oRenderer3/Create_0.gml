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

staticBlocks = new VertexCake();
staticBlocks.Bake(oStaticOccluder, sStaticBlock, 0, true);

sunlight = new BulbSunlight(lighting, 45);
sunlight.blend = c_red;
sunlight.intensity = 1;
sunlight.penumbraSize = 5;