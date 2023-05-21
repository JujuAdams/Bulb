/// @param renderer

function BulbStaticOccluder(_renderer) constructor
{
    x = 0;
    y = 0;
    
    xscale = 1.0;
    yscale = 1.0;
    angle  = 0.0;
    
    //Arranged as repeating units of 8 elements: x1, y1, x2, y2, parent x1, parent y1, parent x2, parent y2
    __edgeArray = [];
    
    __destroyed = false;
    
    static Destroy = function()
    {
        __destroyed = true;
    }
    
    static AddEdge = function(_x1, _y1, _x2, _y2)
    {
        if (__destroyed) return;
        
        array_push(__edgeArray, _x1, _y1, _x2, _y2,
                                _x1, _y1, _x2, _y2);
    }
    
    static ClearEdges = function()
    {
        if (__destroyed) return;
        
        array_resize(__edgeArray, 0);
    }
    
    static SetSprite = function(_sprite, _image)
    {
        if (__destroyed) return;
        
        ClearEdges();
        AddSprite(_sprite, _image);
    }
    
    static SetTilemap = function(_tilemap)
    {
        if (__destroyed) return;
        
        ClearEdges();
        AddTilemap(_tilemap);
    }
    
    static AddSprite = function(_sprite, _image, _xOffset = 0, _yOffset = 0)
    {
        if (__destroyed) return;
        
        __BulbAddSpriteToOccluder(self, _sprite, _image, _xOffset, _yOffset, false);
    }
    
    static AddTilemap = function(_tilemap)
    {
        if (__destroyed) return;
        
        if (is_string(_tilemap)) _tilemap = layer_tilemap_get_id(_tilemap);
        __BulbAddTilemapToOccluder(self, _tilemap);
    }
    
    static AddToRenderer = function(_renderer)
    {
        if (__destroyed) return;
        
        array_push(_renderer.__staticOccludersArray, weak_ref_create(self));
    }
    
    static RemoveFromRenderer = function(_renderer)
    {
        var _array = _renderer.__staticOccludersArray;
        var _i = array_length(_array) - 1;
        repeat(array_length(_array))
        {
            var _weak = _array[_i];
            if (weak_ref_alive(_weak))
            {
                if (_weak.ref == self) array_delete(_array, _i, 1);
            }
            else
            {
                array_delete(_array, _i, 1);
            }
            
            --_i;
        }
    }
    
    if (_renderer != undefined) AddToRenderer(_renderer);
}