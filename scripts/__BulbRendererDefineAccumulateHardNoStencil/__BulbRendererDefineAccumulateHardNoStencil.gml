// Feather disable all

function __BulbRendererDefineAccumulateHardNoStencil()
{
    __AccumulateHardLights = function(_boundaryL, _boundaryT, _boundaryR, _boundaryB, _cameraCX, _cameraCY, _cameraW, _cameraH, _cameraCos, _cameraSin, _normalCoeff)
    {
        static _shdBulbHardShadows_u_vLight                   = shader_get_uniform(__shdBulbHardShadows,              "u_vLight"      );
        static _shdBulbHardShadows_u_fNormalCoeff             = shader_get_uniform(__shdBulbHardShadows,              "u_fNormalCoeff");
        static _shdBulbHardShadowsSunlight_u_vLightVector     = shader_get_uniform(__shdBulbHardShadowsSunlight,      "u_vLightVector");
        static _shdBulbHardShadowsSunlight_u_fNormalCoeff     = shader_get_uniform(__shdBulbHardShadowsSunlight,      "u_fNormalCoeff");
        static _shdBulbLightWithNormalMap_u_vInfo             = shader_get_uniform(__shdBulbLightWithNormalMap,       "u_vInfo"       );
        static _shdBulbLightWithoutNormalMap_u_fIntensity     = shader_get_uniform(__shdBulbLightWithoutNormalMap,    "u_fIntensity"  );
        static _shdBulbSunlightWithNormalMap_u_vSunInfo       = shader_get_uniform(__shdBulbSunlightWithNormalMap,    "u_vInfo"       );
        static _sshdBulbSunlightWithoutNormalMap_u_fIntensity = shader_get_uniform(__shdBulbSunlightWithoutNormalMap, "u_fIntensity"  );
        
        var _staticVBuffer  = __staticVBuffer;
        var _dynamicVBuffer = __dynamicVBuffer;
        
        var _rendererNormalMap = normalMap;
        if (_rendererNormalMap)
        {
            shader_set(__shdBulbLightWithNormalMap);
            texture_set_stage(shader_get_sampler_index(__shdBulbLightWithNormalMap, "u_sNormalMap"), surface_get_texture(GetNormalMapSurface()));
            shader_set_uniform_f(shader_get_uniform(__shdBulbLightWithNormalMap, "u_vCamera"), _cameraCX, _cameraCY, _cameraW/2, _cameraH/2);
            shader_set_uniform_f(shader_get_uniform(__shdBulbLightWithNormalMap, "u_vCameraVector"), _cameraCos, _cameraSin);
            shader_set_uniform_f(shader_get_uniform(__shdBulbLightWithNormalMap, "u_fSpecularIntensity"), hdr? BULB_SPECULAR_MAP_INTENSITY : 0);
            
            shader_set(__shdBulbSunlightWithNormalMap);
            shader_set_uniform_f(shader_get_uniform(__shdBulbSunlightWithNormalMap, "u_fSpecularIntensity"), hdr? BULB_SPECULAR_MAP_INTENSITY : 0);
        }
        
        //bm_max requires some trickery with alpha to get good-looking results
        //Determine the blend mode and "default" shader accordingly
        gpu_set_blendmode(bm_add);
        
        //Set up the coefficient to flip normals
        //We use this to control self-renderer
        shader_set(__shdBulbHardShadows);
        shader_set_uniform_f(_shdBulbHardShadows_u_fNormalCoeff, _normalCoeff);
        
        //Also do the same for our sunlight shader, provided we have any sunlight sources
        if (array_length(__sunlightArray) > 0)
        {
            shader_set(__shdBulbHardShadowsSunlight);
            shader_set_uniform_f(_shdBulbHardShadowsSunlight_u_fNormalCoeff, _normalCoeff);
        }
        
        //Set our default shader
        shader_reset();
        gpu_set_colorwriteenable(true, true, true, false);
        
        //And switch on z-testing. We'll use z-testing for stenciling
        gpu_set_ztestenable(true);
        gpu_set_zwriteenable(true);
        gpu_set_zfunc(cmpfunc_lessequal);
        
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
                        if (__IsOnScreen(_boundaryL, _boundaryT, _boundaryR, _boundaryB))
                        {
                            if (castShadows)
                            {
                                //Turn off all RGBA writing, leaving only z-writing
                                gpu_set_colorwriteenable(false, false, false, false);
                                
                                //Guarantee that we're going to write to the z-buffer with the next operations
                                gpu_set_zfunc(cmpfunc_always);
                                
                                //Reset z-buffer
                                draw_sprite_ext(sprite, image,
                                                x, y,
                                                xscale, yscale, angle,
                                                c_black, 1);
                                
                                //Stencil out shadow areas
                                shader_set(__shdBulbHardShadows);
                                shader_set_uniform_f(_shdBulbHardShadows_u_vLight, x, y);
                                vertex_submit(_staticVBuffer,  pr_trianglelist, -1);
                                vertex_submit(_dynamicVBuffer, pr_trianglelist, -1);
                                
                                //Swap to drawing RGB data (no alpha to make the output surface tidier)
                                gpu_set_colorwriteenable(true, true, true, false);
                                gpu_set_zfunc(cmpfunc_lessequal);
                                
                                //Reset shader and draw the light itself, but "behind" the shadows
                                if (_rendererNormalMap && normalMap)
                                {
                                    shader_set(__shdBulbLightWithNormalMap);
                                    shader_set_uniform_f(_shdBulbLightWithNormalMap_u_vInfo, x, y, normalMapZ, intensity);
                                }
                                else
                                {
                                    shader_set(__shdBulbLightWithoutNormalMap);
                                    shader_set_uniform_f(_shdBulbLightWithoutNormalMap_u_fIntensity, intensity);
                                }
                                
                                draw_sprite_ext(sprite, image, x, y, xscale, yscale, angle, blend, 1);
                            }
                            else
                            {
                                //Just draw the sprite, no fancy stuff here
                                if (_rendererNormalMap && normalMap)
                                {
                                    shader_set(__shdBulbLightWithNormalMap);
                                    shader_set_uniform_f(_shdBulbLightWithNormalMap_u_vInfo, x, y, normalMapZ, intensity);
                                }
                                else
                                {
                                    shader_set(__shdBulbLightWithoutNormalMap);
                                    shader_set_uniform_f(_shdBulbLightWithoutNormalMap_u_fIntensity, intensity);
                                }
                                
                                draw_sprite_ext(sprite, image, x, y, xscale, yscale, angle, blend, 1);
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
                        //Turn off all RGBA writing, leaving only z-writing
                        gpu_set_colorwriteenable(false, false, false, false);
                        
                        //Guarantee that we're going to write to the z-buffer with the next operations
                        gpu_set_zfunc(cmpfunc_always);
                        
                        //Full surface clear of the z-buffer
                        draw_sprite_ext(__sprBulbPixel, 0, _boundaryL, _boundaryT, _boundaryR - _boundaryL, _boundaryB - _boundaryT, 0, c_black, 0);
                        
                        //Stencil out shadow areas
                        shader_set(__shdBulbHardShadowsSunlight);
                        shader_set_uniform_f(_shdBulbHardShadowsSunlight_u_vLightVector, dcos(angle), -dsin(angle));
                        vertex_submit(_staticVBuffer,  pr_trianglelist, -1);
                        vertex_submit(_dynamicVBuffer, pr_trianglelist, -1);
                        
                        //Swap to drawing RGB data (no alpha to make the output surface tidier)
                        gpu_set_colorwriteenable(true, true, true, false);
                        gpu_set_zfunc(cmpfunc_lessequal);
                        
                        //Reset shader and draw the light itself, but "behind" the shado
                        if (_rendererNormalMap && normalMap)
                        {
                            shader_set(__shdBulbSunlightWithNormalMap);
                            shader_set_uniform_f(_shdBulbSunlightWithNormalMap_u_vSunInfo, dcos(angle), -dsin(angle), normalMapZ, intensity);
                        }
                        else
                        {
                            shader_set(__shdBulbLightWithoutNormalMap);
                            shader_set_uniform_f(_shdBulbLightWithoutNormalMap_u_fIntensity, intensity);
                        }
                        
                        
                        draw_sprite_ext(__sprBulbPixel, 0, _boundaryL, _boundaryT, _boundaryR - _boundaryL, _boundaryB - _boundaryT, 0, blend, 1);
                    }
                }
                
                ++_i;
            }
        }
        
        shader_reset();
        gpu_set_colorwriteenable(true, true, true, true);
        gpu_set_blendmode(bm_normal);
        
        gpu_set_zfunc(cmpfunc_lessequal);
        gpu_set_ztestenable(false);
        gpu_set_zwriteenable(false);
    }
}