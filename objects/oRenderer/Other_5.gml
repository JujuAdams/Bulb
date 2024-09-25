//Destroy the camera we set up
view_set_camera(0, noone);
camera_destroy(camera);

//Destroy the walls vertex buffer
staticBlocks.Free();

//Destroy the renderer system (you still need to destroy each light instance!)
renderer.Free();