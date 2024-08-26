var _t = get_timer();
BulbDrawLitApplicationSurface(renderer);
drawEndTime = get_timer() - _t;

if (keyboard_check(ord("N")))
{
    renderer.DrawNormalMapDebug(0, 0, 1280, 720);
}