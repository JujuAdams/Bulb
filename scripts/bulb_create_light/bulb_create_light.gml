/// @param renderer
/// @param sprite
/// @param image
/// @param x
/// @param y

function bulb_create_light(_renderer, _sprite, _image, _x, _y)
{
    with(new __bulb_class_light())
    {
        sprite = _sprite;
        image  = _image;
        x      = _x;
        y      = _y;
        
        add_to_renderer(_renderer);
        return self;
    }
}

function __bulb_class_light() constructor
{
    visible = true;
    
    sprite = undefined;
    image  = undefined;
    x      = undefined;
    y      = undefined;
    xscale = 1.0;
    yscale = 1.0;
    angle  = 0.0;
    blend  = c_white;
    alpha  = 1.0;
    
    penumbra_size = 0.0;
    
    cast_shadows = true;
    
    __old_sprite  = undefined;
    __width_half  = 0;
    __height_half = 0;
    
    static add_to_renderer = function(_renderer)
    {
        array_push(_renderer.lights_array, weak_ref_create(self));
    }
    
    static remove_from_rendere = function(_renderer)
    {
        var _array = _renderer.lights_array;
        var _i = array_length(_array) - 1;
        repeat(array_length(_array))
        {
            var _weak_ref = _array[_i];
            if (weak_ref_alive(_weak_ref))
            {
                if (_weak_ref.ref == self) array_delete(_array, _i, 1);
            }
            else
            {
                array_delete(_array, _i, 1);
            }
            
            --_i;
        }
    }
    
    static __is_on_screen = function(_camera_l, _camera_t, _camera_r, _camera_b)
    {
        return (visible && __bulb_rect_in_rect(x - __width_half, y - __height_half, x + __width_half, y + __height_half, _camera_l, _camera_t, _camera_r, _camera_b));
    }
    
    static __check_sprite_dimensions = function()
    {
        if (sprite != __old_sprite)
        {
            __old_sprite = sprite;
            
            __width_half  = 0.5*xscale*sprite_get_width(sprite);
            __height_half = 0.5*yscale*sprite_get_height(sprite);
        }
    }
}