//Destroy the camera we set up
view_set_camera(0, noone);
camera_destroy(camera);

//Destroy the walls vertex buffer
static_blocks.free();

//Destroy the lighting system (you still need to destroy each light instance!)
lighting.free();