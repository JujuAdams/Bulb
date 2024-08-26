//Draw the application surface to the screen
BulbDrawLitApplicationSurface(renderer);

if (keyboard_check(ord("N")))
{
    renderer.DrawNormalMapDebug(0, 0, 1280, 720);
}