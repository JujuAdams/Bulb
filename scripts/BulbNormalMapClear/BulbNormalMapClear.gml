// Feather disable all

function BulbNormalMapClear()
{
    static _u_fAlphaThreshold = shader_get_uniform(__shdBulbNormal, "u_fAlphaThreshold");
    
    //Re-set the alpha threshold just in case
    var _shader = shader_current();
    shader_set(__shdBulbNormal);
    shader_set_uniform_f(_u_fAlphaThreshold, BULB_NORMAL_MAP_ALPHA_THRESHOLD);
    shader_set(_shader);
    
    draw_clear(#0000FF);
}