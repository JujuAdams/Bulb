// Feather disable all

/// @param [forceFlat=false]

function BulbNormalMapShaderSet(_forceFlat = false)
{
    shader_set(_forceFlat? __shdBulbNormalUp : __shdBulbNormal);
    gpu_set_colorwriteenable(true, true, true, false);
}