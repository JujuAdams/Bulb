// HDR references:
// https://www.shadertoy.com/view/WdjSW3
// https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/
// https://64.github.io/tonemapping/
// http://slideshare.net/ozlael/hable-john-uncharted2-hdr-renderer
// http://filmicgames.com/archives/75
// http://filmicgames.com/archives/183
// http://filmicgames.com/archives/190
// http://imdoingitwrong.wordpress.com/2010/08/19/why-reinhard-desaturates-my-blacks-3/
// http://mynameismjp.wordpress.com/2010/04/30/a-closer-look-at-tone-mapping/
// http://renderwonk.com/publications/s2010-color-course/
// https://mini.gmshaders.com/p/tonemaps
// http://filmicworlds.com/blog/filmic-tonemapping-operators/

#macro __BULB_ZFAR  1

function __BulbSystem()
{
    static _system = undefined;
    if (_system != undefined) return _system;
    
    __BulbTrace("Welcome to Bulb by Juju Adams! This is version " + BULB_VERSION + ", " + BULB_DATE);
    
    _system = {};
    with(_system)
    {
        try
        {
            var _ = surface_rgba16float;
            
            __BulbTrace("HDR available");
            __hdrAvailable = true;
        }
        catch(_error)
        {
            __BulbTrace("HDR not available");
            __hdrAvailable = false;
        }
        
        try
        {
            gpu_get_stencil_ref();
            __BulbTrace("GPU stencil functions available");
            __hasStencil = true;
        }
        catch(_error)
        {
            __BulbTrace("GPU stencil functions not available");
            __hasStencil = false;
        }
    }
    
    return _system;
}