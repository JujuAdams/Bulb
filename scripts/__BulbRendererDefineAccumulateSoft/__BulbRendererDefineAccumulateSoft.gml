// Feather disable all

function __BulbRendererDefineAccumulateSoft()
{
    __AccumulateSoftLights = function(_cameraL, _cameraT, _cameraR, _cameraB, _cameraCX, _cameraCY, _cameraW, _cameraH, _normalCoeff)
    {
        static _u_vLight                = shader_get_uniform(__shdBulbSoftShadows,           "u_vLight"      );
        static _sunlight_u_vLightVector = shader_get_uniform(__shdBulbSoftShadowsSunlight,   "u_vLightVector");
        static _u_vInfo                 = shader_get_uniform(__shdBulbLightWithNormalMap,    "u_vInfo"       );
        static _u_vSunInfo              = shader_get_uniform(__shdBulbSunlightWithNormalMap, "u_vInfo"       );
        
        var _staticVBuffer  = __staticVBuffer;
        var _dynamicVBuffer = __dynamicVBuffer;
        
        shader_set(__shdBulbLightWithNormalMap);
        texture_set_stage(shader_get_sampler_index(__shdBulbLightWithNormalMap, "u_sNormalMap"), surface_get_texture(GetNormalSurface()));
        shader_set_uniform_f(shader_get_uniform(__shdBulbLightWithNormalMap, "u_vCamera"), _cameraCX, _cameraCY, _cameraW/2, _cameraH/2);
        
        var _i = 0;
        repeat(array_length(__lightsArray))
        {
            var _weak = __lightsArray[_i];
            if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
            {
                array_delete(__lightsArray, _i, 1);
            }
            else
            {
                with(_weak.ref)
                {
                    if (visible)
                    {
                        __CheckSpriteDimensions();
                        
                        //If this light is active, do some drawing
                        if (__IsOnScreen(_cameraL, _cameraT, _cameraR, _cameraB))
                        {
                            if (castShadows)
                            {
                                //Only write into the alpha channel
                                gpu_set_colorwriteenable(false, false, false, true);
                                
                                //Clear the alpha channel for the light's visual area
                                gpu_set_blendmode_ext(bm_one, bm_zero);
                                draw_sprite_ext(sprite, image,
                                                x, y,
                                                xscale, yscale, angle,
                                                c_black, 1);
                                
                                //Cut out shadows in the alpha channel
                                gpu_set_blendmode(bm_subtract);
                                
                                shader_set(__shdBulbSoftShadows);
                                shader_set_uniform_f(_u_vLight, x, y, penumbraSize);
                                vertex_submit(_staticVBuffer,  pr_trianglelist, -1);
                                vertex_submit(_dynamicVBuffer, pr_trianglelist, -1);
                                
                                //Set the light sprite to borrowing the alpha channel already on the surface
                                gpu_set_colorwriteenable(true, true, true, false);
                                gpu_set_blendmode_ext(bm_dest_alpha, bm_one);
                                
                                //Draw light sprite
                                shader_set(__shdBulbLightWithNormalMap);
                                shader_set_uniform_f(_u_vInfo, x, y, normalMapZ, intensity);
                                draw_sprite_ext(sprite, image,
                                                x, y,
                                                xscale, yscale, angle,
                                                blend, 1);
                            }
                            else
                            {
                                //No shadows - draw the light sprite normally
                                gpu_set_blendmode(bm_add);
                                shader_set_uniform_f(_u_vInfo, x, y, normalMapZ, intensity);
                                draw_sprite_ext(sprite, image,
                                                x, y,
                                                xscale, yscale, angle,
                                                blend, 1);
                            }
                        }
                    }
                }
                
                ++_i;
            }
        }
        
        var _i = 0;
        repeat(array_length(__sunlightArray))
        {
            var _weak = __sunlightArray[_i];
            if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
            {
                array_delete(__sunlightArray, _i, 1);
            }
            else
            {
                with(_weak.ref)
                {
                    if (visible)
                    {
                        //Only write into the alpha channel
                        gpu_set_colorwriteenable(false, false, false, true);
                        
                        //Clear the alpha channel for the light's visual area
                        gpu_set_blendmode_ext(bm_one, bm_zero);
                        draw_sprite_ext(__sprBulbPixel, 0, _cameraL, _cameraT, _cameraW+1, _cameraH+1, 0, c_black, 1);
                        
                        //Cut out shadows in the alpha channel
                        gpu_set_blendmode(bm_subtract);
                        
                        shader_set(__shdBulbSoftShadowsSunlight);
                        shader_set_uniform_f(_sunlight_u_vLightVector, dcos(angle), -dsin(angle), penumbraSize);
                        vertex_submit(_staticVBuffer,  pr_trianglelist, -1);
                        vertex_submit(_dynamicVBuffer, pr_trianglelist, -1);
                        
                        //Set the light sprite to borrowing the alpha channel already on the surface
                        gpu_set_colorwriteenable(true, true, true, false);
                        gpu_set_blendmode_ext(bm_dest_alpha, bm_one);
                        
                        //Draw light sprite
                        shader_set(__shdBulbSunlightWithNormalMap);
                        shader_set_uniform_f(_u_vSunInfo, dcos(angle), -dsin(angle), normalMapZ, intensity);
                        draw_sprite_ext(__sprBulbPixel, 0, _cameraL, _cameraT, _cameraW+1, _cameraH+1, 0, blend, 1);
                    }
                }
                
                ++_i;
            }
        }
        
        shader_reset();
        gpu_set_blendmode(bm_normal);
    }
}