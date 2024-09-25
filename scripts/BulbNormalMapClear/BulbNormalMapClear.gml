// Feather disable all

/// @param [baseSpecular=0]

function BulbNormalMapClear(_baseSpecular = 0)
{
    static _u_fAlphaThreshold_Normal        = shader_get_uniform(__shdBulbNormal, "u_fAlphaThreshold");
    static _u_fAlphaThreshold_Specular      = shader_get_uniform(__shdBulbSpecular, "u_fAlphaThreshold");
    static _u_fAlphaThreshold_SpecularForce = shader_get_uniform(__shdBulbSpecularForce, "u_fAlphaThreshold");
    
    //Re-set the alpha threshold just in case
    var _shader = shader_current();
    
    shader_set(__shdBulbNormal);
    shader_set_uniform_f(_u_fAlphaThreshold_Normal, BULB_NORMAL_MAP_ALPHA_THRESHOLD);
    
    shader_set(__shdBulbSpecular);
    shader_set_uniform_f(_u_fAlphaThreshold_Specular, BULB_NORMAL_MAP_ALPHA_THRESHOLD);
    
    shader_set(__shdBulbSpecularForce);
    shader_set_uniform_f(_u_fAlphaThreshold_SpecularForce, BULB_NORMAL_MAP_ALPHA_THRESHOLD);
    
    shader_set(_shader);
    
    draw_clear_alpha(#0000FF, 1 - _baseSpecular);
}