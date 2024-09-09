// Feather disable all

/// @param [forceValue=false]

function BulbSpecularMapShaderSet(_forceValue = false)
{
    shader_set(_forceValue? __shdBulbSpecularForce : __shdBulbSpecular);
    gpu_set_colorwriteenable(false, false, false, true);
    gpu_set_blendmode_ext(bm_one, bm_zero);
}