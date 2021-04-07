/// @param group1
/// @param [group2]
/// @param [group3]
/// @param ...

function BulbMakeBitmask()
{
    var _value = 0;
    
    var _i = 0;
    repeat(argument_count)
    {
        if (argument[_i]) _value |= (1 << _i);
        ++_i;
    }
    
    return _value;
}