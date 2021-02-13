/// @param renderer

function bulb_create_dynamic_occluder(_renderer)
{
    with(new __bulb_class_dynamic_occluder())
    {
        add_to_renderer(_renderer);
        return self;
    }
}

function __bulb_class_dynamic_occluder() constructor
{
    visible = true;
    
    x = 0;
    y = 0;
    
    xscale = 1.0;
    yscale = 1.0;
    angle  = 0.0;
    
    __bbox_x_min = 0;
    __bbox_x_max = 0;
    __bbox_y_min = 0;
    __bbox_y_max = 0;
    
    vertex_array = [];
    
    static add_edge = function(_x1, _y1, _x2, _y2)
    {
        __bbox_x_min = min(__bbox_x_min, __BULB_SQRT_2*_x1, __BULB_SQRT_2*_x2);
        __bbox_y_min = min(__bbox_y_min, __BULB_SQRT_2*_y1, __BULB_SQRT_2*_y2);
        __bbox_x_max = max(__bbox_x_max, __BULB_SQRT_2*_x1, __BULB_SQRT_2*_x2);
        __bbox_y_max = max(__bbox_y_max, __BULB_SQRT_2*_y1, __BULB_SQRT_2*_y2);
        
        array_push(vertex_array, _x1, _y1, _x2, _y2);
    }
    
    static clear_edges = function(_x1, _y1, _x2, _y2)
    {
        __bbox_x_min = 0;
        __bbox_x_max = 0;
        __bbox_y_min = 0;
        __bbox_y_max = 0;
        
        array_resize(vertex_array, 0);
    }
    
    static add_to_renderer = function(_renderer)
    {
        array_push(_renderer.dynamic_occluders_array, weak_ref_create(self));
    }
    
    static remove_from_rendere = function(_renderer)
    {
        var _array = _renderer.dynamic_occluders_array;
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
        return (visible && __bulb_rect_in_rect(x + __bbox_x_min, y + __bbox_y_min, x + __bbox_x_max, y + __bbox_y_max, _camera_l, _camera_t, _camera_r, _camera_b));
    }
}