// Feather disable all

function BulbSpecularMapShaderReset()
{
    shader_reset();
    gpu_set_colorwriteenable(true, true, true, true);
    gpu_set_blendmode(bm_normal);
}