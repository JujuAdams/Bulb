// Feather disable all

/// @param forceUpNormal

function BulbNormalMapShaderSet(_forceUpNormal)
{
    shader_set(_forceUpNormal? __shdBulbNormalUp : __shdBulbNormal);
}