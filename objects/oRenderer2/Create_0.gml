application_surface_draw_enable(false);

view_enabled = true;
view_set_visible(0, true);
camera = camera_create_view(x - 640, y - 360,   1280, 720, 0,   noone, 0, 0, 0, 0);
view_set_camera(0, camera);

renderer = new BulbRenderer();
renderer.soft = false;
renderer.ldrTonemap = BULB_TONEMAP_ACES;

staticBlocks = new VertexCake();