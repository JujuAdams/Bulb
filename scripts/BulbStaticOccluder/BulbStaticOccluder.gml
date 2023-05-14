/// @param renderer

function BulbStaticOccluder(_renderer) constructor
{
    x = 0;
    y = 0;
    
    xscale = 1.0;
    yscale = 1.0;
    angle  = 0.0;
    
    //Arranged as repeating units of 6 elements: x1, y1, x2, y2, normal x, normal y
    //The normal vector does *not* need to be of unit length
    vertexArray = [];
    
    __destroyed = false;
    
    static Destroy = function()
    {
        __destroyed = true;
    }
    
    static AddEdge = function(_x1, _y1, _x2, _y2, _x3 = _x1, _y3 = _y1, _x4 = _x2, _y4 = _y2)
    {
        if (__destroyed) return;
        
        array_push(vertexArray, _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4);
    }
    
    static ClearEdges = function()
    {
        if (__destroyed) return;
        
        array_resize(vertexArray, 0);
    }
    
    static SetSprite = function(_sprite, _image)
    {
        ClearEdges();
        AddSprite(_sprite, _image);
    }
    
    static SetTilemap = function(_tilemap)
    {
        ClearEdges();
        AddTilemap(_tilemap);
    }
    
    static AddSprite = function(_sprite, _image, _xOffset = 0, _yOffset = 0)
    {
        __BulbAddSpriteToOccluder(self, _sprite, _image, _xOffset, _yOffset);
    }
    
    static AddTilemap = function(_tilemap)
    {
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