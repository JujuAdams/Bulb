// Feather disable all

function __BulbRendererDefineAccumulateHard()
{
    __AccumulateHardLights = function(_cameraL, _cameraT, _cameraR, _cameraB, _cameraCX, _cameraCY, _cameraW, _cameraH, _normalCoeff)
    {
        static _u_vLight                = shader_get_uniform(__shdBulbHardShadows,           "u_vLight"      );
        static _u_fNormalCoeff          = shader_get_uniform(__shdBulbHardShadows,           "u_fNormalCoeff");
        static _sunlight_u_vLightVector = shader_get_uniform(__shdBulbHardShadowsSunlight,   "u_vLightVector");
        static _sunlight_u_fNormalCoeff = shader_get_uniform(__shdBulbHardShadowsSunlight,   "u_fNormalCoeff");
        static _u_fIntensity            = shader_get_uniform(__shdBulbLightWithoutNormalMap, "u_fIntensity"  );
        
        var _staticVBuffer  = __staticVBuffer;
        var _dynamicVBuffer = __dynamicVBuffer;
        
        //bm_max requires some trickery with alpha to get good-looking results
        //Determine the blend mode and "default" shader accordingly
        gpu_set_blendmode(bm_add);
        
        //Set up the coefficient to flip normals
        //We use this to control self-lighting
        shader_set(__shdBulbHardShadows);
        shader_set_uniform_f(_u_fNormalCoeff, _normalCoeff);
        
        //Also do the same for our sunlight shader, provided we have any sunlight sources
        if (array_length(__sunlightArray) > 0)
        {
            shader_set(__shdBulbHardShadowsSunlight);
            shader_set_uniform_f(_sunlight_u_fNormalCoeff, _normalCoeff);
        }
        
        //Set our default shader
        shader_set(__shdBulbIntensity);
        
        gpu_set_colorwriteenable(true, true, true, false);
        
        draw_clear_stencil(0);
        gpu_set_stencil_enable(true);
        gpu_set_stencil_pass(stencilop_replace);
        gpu_set_stencil_fail(stencilop_keep);
        gpu_set_stencil_depth_fail(stencilop_keep);
        gpu_set_stencil_func(cmpfunc_always);
        var _stencil = 0;
        
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
                                ++_stencil;
                                if (_stencil >= 256)
                                {
                                    draw_clear_stencil(0);
                                    _stencil = 1;
                                }
                                
                                gpu_set_stencil_ref(_stencil);
                                
                                //Stencil out shadow areas
                                shader_set(__shdBulbHardShadows);
                                shader_set_uniform_f(_u_vLight, x, y);
                                
                                vertex_submit(_staticVBuffer,  pr_trianglelist, -1);
                                vertex_submit(_dynamicVBuffer, pr_trianglelist, -1);
                                
                                //Reset shader and draw the light itself, but "behind" the shadows
                                shader_set(__shdBulbLightWithoutNormalMap);
                                shader_set_uniform_f(_u_fIntensity, intensity);
                                
                                gpu_set_stencil_func(cmpfunc_greater);
                                draw_sprite_ext(sprite, image, x, y, xscale, yscale, angle, blend, 1);
                                gpu_set_stencil_func(cmpfunc_always);
                            }
                            else
                            {
                                //Just draw the sprite, no fancy stuff here
                                shader_set_uniform_f(_u_fIntensity, intensity);
                                draw_sprite_ext(sprite, image, x, y, xscale, yscale, angle, blend, 1);
                            }
                        }
                    }
                }
                
                ++_i;
            }
        }
        
        gpu_set_stencil_enable(true);
        
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
                        ++_stencil;
                        if (_stencil >= 256)
                        {
                            draw_clear_stencil(0);
                            _stencil = 1;
                        }
                        
                        gpu_set_stencil_ref(_stencil);
                        
                        //Stencil out shadow areas
                        shader_set(__shdBulbHardShadowsSunlight);
                        shader_set_uniform_f(_sunlight_u_vLightVector, dcos(angle), -dsin(angle));
                        
                        vertex_submit(_staticVBuffer,  pr_trianglelist, -1);
                        vertex_submit(_dynamicVBuffer, pr_trianglelist, -1);
                        
                        //Reset shader and draw the light itself, but "behind" the shadows
                        shader_set(__shdBulbLightWithoutNormalMap);
                        shader_set_uniform_f(_u_fIntensity, intensity);
                                
                        gpu_set_stencil_func(cmpfunc_greater);
                        draw_sprite_ext(__sprBulbPixel, 0, _cameraL, _cameraT, _cameraW+1, _cameraH+1, 0, blend, 1);
                        gpu_set_stencil_func(cmpfunc_always);
                    }
                }
                
                ++_i;
            }
        }
        
        shader_reset();
        gpu_set_colorwriteenable(true, true, true, true);
        gpu_set_blendmode(bm_normal);
        gpu_set_stencil_enable(false);
    }
}