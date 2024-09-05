// Feather disable all

function __BulbRendererDefineOverlayUnderlay()
{
    __ambienceSpriteArray = [];
    __shadowOverlayArray  = [];
    __lightOverlayArray   = [];
    
    __AccumulateAmbienceSprite = function(_boundaryL, _boundaryT, _boundaryR, _boundaryB)
    {
        //Now draw ambience overlay sprites, if we have any
        var _size = array_length(__ambienceSpriteArray);
        if (_size > 0)
        {
            gpu_set_colorwriteenable(true, true, true, false);
            
            var _i = 0;
            repeat(_size)
            {
                var _weak = __ambienceSpriteArray[_i];
                if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
                {
                    array_delete(__ambienceSpriteArray, _i, 1);
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
                                draw_sprite_ext(sprite, image, x, y, xscale, yscale, angle, blend, alpha);
                            }
                        }
                    }
                    
                    ++_i;
                }
            }
            
            gpu_set_colorwriteenable(true, true, true, true);
        }
    }
    
    __AccumulateShadowOverlay = function(_boundaryL, _boundaryT, _boundaryR, _boundaryB)
    {
        //Now draw shadow overlay sprites, if we have any
        var _size = array_length(__shadowOverlayArray);
        if (_size > 0)
        {
            //Leverage the fog system to force the colour of the sprites we draw (alpha channel passes through)
            gpu_set_fog(true, __GetAmbientColor(), 0, 0);
            
            //Don't touch the alpha channel
            gpu_set_colorwriteenable(true, true, true, false);
            
            var _i = 0;
            repeat(_size)
            {
                var _weak = __shadowOverlayArray[_i];
                if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
                {
                    array_delete(__shadowOverlayArray, _i, 1);
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
                                draw_sprite_ext(sprite, image, x, y, xscale, yscale, angle, c_white, alpha);
                            }
                        }
                    }
                    
                    ++_i;
                }
            }
            
            //Reset render state
            gpu_set_fog(false, c_white, 0, 0);
            gpu_set_colorwriteenable(true, true, true, true);
        }
    }
    
    __AccumulateLightOverlay = function(_boundaryL, _boundaryT, _boundaryR, _boundaryB)
    {
        static _u_fIntensity = shader_get_uniform(__shdBulbIntensity, "u_fIntensity");
        
        shader_set(__shdBulbIntensity);
        
        //We use the overarching blend mode for the renderer
        gpu_set_blendmode(bm_add);
        
        //Don't touch the alpha channel though
        gpu_set_colorwriteenable(true, true, true, false);
        
        var _i = 0;
        repeat(array_length(__lightOverlayArray))
        {
            var _weak = __lightOverlayArray[_i];
            if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
            {
                array_delete(__lightOverlayArray, _i, 1);
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
                            shader_set_uniform_f(_u_fIntensity, intensity);
                            draw_sprite_ext(sprite, image, x, y, xscale, yscale, angle, blend, 1);
                        }
                    }
                }
                
                ++_i;
            }
        }
        
        //Reset render state
        shader_reset();
        gpu_set_fog(false, c_white, 0, 0);
        gpu_set_colorwriteenable(true, true, true, true);
    }
}