// HDR references:
// https://www.shadertoy.com/view/WdjSW3
// https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/
// https://64.github.io/tonemapping/
// http://slideshare.net/ozlael/hable-john-uncharted2-hdr-lighting
// http://filmicgames.com/archives/75
// http://filmicgames.com/archives/183
// http://filmicgames.com/archives/190
// http://imdoingitwrong.wordpress.com/2010/08/19/why-reinhard-desaturates-my-blacks-3/
// http://mynameismjp.wordpress.com/2010/04/30/a-closer-look-at-tone-mapping/
// http://renderwonk.com/publications/s2010-color-course/
// https://mini.gmshaders.com/p/tonemaps
// http://filmicworlds.com/blog/filmic-tonemapping-operators/

#macro __BULB_ZFAR  1

__BulbTrace("Welcome to Bulb by Juju Adams! This is version " + BULB_VERSION + ", " + BULB_DATE);

function __BulbTrace()
{
    var _string = "";
    
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_debug_message("Bulb: " + _string);
}

function __BulbError()
{
    var _string = "";
    
    var _i = 0
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_debug_message("Bulb: " + string_replace_all(_string, "\n", "\n          "));
    show_error("Bulb:\n" + _string + "\n ", true);
}

function __BulbRectInRect(_ax1, _ay1, _ax2, _ay2, _bx1, _by1, _bx2, _by2)
{
    return !((_bx1 > _ax2) || (_bx2 < _ax1) || (_by1 > _ay2) || (_by2 < _ay1));
}