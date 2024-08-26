/// @param object
/// @param sprite
/// @param image
/// @param freeze

//Create a basic vertex format
vertex_format_begin();
vertex_format_add_position();
vertex_format_add_colour();
vertex_format_add_texcoord();
global.__vertex_cake_format = vertex_format_end();

function VertexCake() constructor
{
    object        = undefined;
    sprite        = undefined;
    image         = undefined;
    texture       = undefined;
    vertex_buffer = undefined;
    
    static Bake = function(_object, _sprite, _image, _freeze)
    {
        Free();
        
        object  = _object;
        sprite  = _sprite;
        image   = _image;
        texture = sprite_get_texture(_sprite, _image);
        
        if (instance_number(_object) > 0)
        {
            var _vbuff = vertex_create_buffer();
            vertex_begin(_vbuff, global.__vertex_cake_format);
        
            with(_object)
            {
                var _uvs = sprite_get_uvs(_sprite, _image);
            
                //TODO - Optimise this
                var _matrix = matrix_build(-sprite_get_xoffset(_sprite), -sprite_get_yoffset(_sprite), 0,
                                            0, 0, 0,
                                            1, 1, 1);
            
                _matrix = matrix_multiply(_matrix, matrix_build(0, 0, 0,
                                                                0, 0, 0,
                                                                image_xscale, image_yscale, 1));
            
                _matrix = matrix_multiply(_matrix, matrix_build(0, 0, 0,
                                                                0, 0, image_angle,
                                                                1, 1, 1));
            
                _matrix = matrix_multiply(_matrix, matrix_build(x, y, 0,
                                                                0, 0, 0,
                                                                1, 1, 1));
            
                //TODO - Optimise this too as well I guess
                var _lt = matrix_transform_vertex(_matrix,                         0,                          0, 0);
                var _rt = matrix_transform_vertex(_matrix, sprite_get_width(_sprite),                          0, 0);
                var _lb = matrix_transform_vertex(_matrix,                         0, sprite_get_height(_sprite), 0);
                var _rb = matrix_transform_vertex(_matrix, sprite_get_width(_sprite), sprite_get_height(_sprite), 0);
            
                vertex_position(_vbuff,   _lt[0], _lt[1]); vertex_colour(_vbuff,   c_white, 1); vertex_texcoord(_vbuff,   _uvs[0], _uvs[1]);
                vertex_position(_vbuff,   _rt[0], _rt[1]); vertex_colour(_vbuff,   c_white, 1); vertex_texcoord(_vbuff,   _uvs[2], _uvs[1]);
                vertex_position(_vbuff,   _lb[0], _lb[1]); vertex_colour(_vbuff,   c_white, 1); vertex_texcoord(_vbuff,   _uvs[0], _uvs[3]);
                                                          
                vertex_position(_vbuff,   _rt[0], _rt[1]); vertex_colour(_vbuff,   c_white, 1); vertex_texcoord(_vbuff,   _uvs[2], _uvs[1]);
                vertex_position(_vbuff,   _rb[0], _rb[1]); vertex_colour(_vbuff,   c_white, 1); vertex_texcoord(_vbuff,   _uvs[2], _uvs[3]);
                vertex_position(_vbuff,   _lb[0], _lb[1]); vertex_colour(_vbuff,   c_white, 1); vertex_texcoord(_vbuff,   _uvs[0], _uvs[3]);
            }
        
            vertex_end(_vbuff);
            if (_freeze) vertex_freeze(_vbuff);
            
            vertex_buffer = _vbuff;
        }
        
        return self;
    }
    
    static Draw = function()
    {
        if (vertex_buffer != undefined) vertex_submit(vertex_buffer, pr_trianglelist, texture);
        
        return self;
    }
    
    static Free = function()
    {
        object  = undefined;
        sprite  = undefined;
        image   = undefined;
        texture = undefined;
        
        if (vertex_buffer != undefined)
        {
            vertex_delete_buffer(vertex_buffer);
            vertex_buffer = undefined;
        }
        
        return self;
    }
}