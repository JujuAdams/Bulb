var _t = get_timer();
BulbDrawLitApplicationSurface(lighting);
drawEndTime = get_timer() - _t;

if (keyboard_check(ord("N")))
{
    lighting.DrawNormalSurfaceDebug(0, 0, 1280, 720);
}