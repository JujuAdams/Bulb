#macro __BULB_VERSION         "20.4.0"
#macro __BULB_DATE            "2023-10-31"
#macro __BULB_ZFAR            1

__BulbTrace("Welcome to Bulb by Juju Adams! This is version " + __BULB_VERSION + ", " + __BULB_DATE);

//Create a couple vertex formats
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_normal();
global.__bulb_format_3d_normal = vertex_format_end();

vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_normal();
vertex_format_add_texcoord();
global.__bulb_format_3d_normal_tex = vertex_format_end();



function __BulbTrace()
{
    var _string = "";
    
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_debug_message("Bulb: " + _string);
}

function __BulbError()
{
    var _string = "";
    
    var _i = 0
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_debug_message("Bulb: " + string_replace_all(_string, "\n", "\n          "));
    show_error("Bulb:\n" + _string + "\n ", true);
}

function __BulbRectInRect(_ax1, _ay1, _ax2, _ay2, _bx1, _by1, _bx2, _by2)
{
    return !((_bx1 > _ax2) || (_bx2 < _ax1) || (_by1 > _ay2) || (_by2 < _ay1));
}