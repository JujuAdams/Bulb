if ( vbf_static_shadows >= 0 )
{
    vertex_delete_buffer( vbf_static_shadows );
    vbf_static_shadows = noone;
}

if ( vbf_dynamic_shadows >= 0 )
{
    vertex_delete_buffer( vbf_dynamic_shadows );
    vbf_dynamic_shadows = noone;
}