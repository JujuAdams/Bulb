// Feather disable all

function __BulbRendererDefineVertexBuffers()
{
    __staticVBuffer  = undefined; //Vertex buffer describing the geometry of static occluder objects
    __dynamicVBuffer = undefined; //As above but for dynamic shadow occluders. This is updated every step
    
    __staticOccludersArray  = [];
    __dynamicOccludersArray = [];
    
    RefreshStaticOccluders = function()
    {
        if (__staticVBuffer != undefined)
        {
            vertex_delete_buffer(__staticVBuffer);
            __staticVBuffer = undefined;
        }
    }
    
    __FreeVertexBuffers = function()
    {
        if (__staticVBuffer != undefined)
        {
            vertex_delete_buffer(__staticVBuffer);
            __staticVBuffer = undefined;
        }
        
        if (__dynamicVBuffer != undefined)
        {
            vertex_delete_buffer(__dynamicVBuffer);
            __dynamicVBuffer = undefined;
        }
    }
    
    __UpdateVertexBuffers = function(_boundaryL, _boundaryT, _boundaryR, _boundaryB)
    {
        //One-time construction of the static occluder geometry
        if (__staticVBuffer == undefined)
        {
            //Create a new vertex buffer
            __staticVBuffer = vertex_create_buffer();
            var _staticVBuffer = __staticVBuffer;
            
            //Add static shadow caster vertices to the relevant vertex buffer
            if (soft)
            {
                vertex_begin(__staticVBuffer, _vformat3DNormalTex);
                
                var _array = __staticOccludersArray;
                var _i = 0;
                repeat(array_length(_array))
                {
                    var _weak = _array[_i];
                    if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
                    {
                        array_delete(_array, _i, 1);
                    }
                    else
                    {
                        with(_weak.ref) __BulbAddOcclusionSoft(_staticVBuffer);
                        ++_i;
                    }
                }
            }
            else
            {
                vertex_begin(__staticVBuffer, _vformat3DNormal);
                
                var _array = __staticOccludersArray;
                var _i = 0;
                repeat(array_length(_array))
                {
                    var _weak = _array[_i];
                    if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
                    {
                        array_delete(_array, _i, 1);
                    }
                    else
                    {
                        with(_weak.ref) __BulbAddOcclusionHard(_staticVBuffer);
                        ++_i;
                    }
                }
            }
            
            vertex_end(__staticVBuffer);
            
            //Freeze this buffer for speed boosts later on (though only if we have vertices in this buffer)
            if (vertex_get_number(__staticVBuffer) > 0) vertex_freeze(__staticVBuffer);
        }
        
        //Refresh the dynamic occluder geometry
        if (__dynamicVBuffer == undefined) __dynamicVBuffer = vertex_create_buffer();
        var _dynamicVBuffer = __dynamicVBuffer;
        
        //Add dynamic occluder vertices to the relevant vertex buffer
        if (soft)
        {
            vertex_begin(_dynamicVBuffer, _vformat3DNormalTex);
            
            var _array = __dynamicOccludersArray;
            var _i = 0;
            repeat(array_length(_array))
            {
                var _weak = _array[_i];
                if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
                {
                    array_delete(_array, _i, 1);
                }
                else
                {
                    with(_weak.ref)
                    {
                        if (__IsOnScreen(_boundaryL, _boundaryT, _boundaryR, _boundaryB)) __BulbAddOcclusionSoft(_dynamicVBuffer);
                    }
                    
                    ++_i;
                }
            }
        }
        else
        {
            vertex_begin(_dynamicVBuffer, _vformat3DNormal);
            
            var _array = __dynamicOccludersArray;
            var _i = 0;
            repeat(array_length(_array))
            {
                var _weak = _array[_i];
                if (!weak_ref_alive(_weak) || _weak.ref.__destroyed)
                {
                    array_delete(_array, _i, 1);
                }
                else
                {
                    with(_weak.ref)
                    {
                        if (__IsOnScreen(_boundaryL, _boundaryT, _boundaryR, _boundaryB)) __BulbAddOcclusionHard(_dynamicVBuffer);
                    }
                    
                    ++_i;
                }
            }
        }
        
        vertex_end(_dynamicVBuffer);
    }
}