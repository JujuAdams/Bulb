#define scr_lighting_build
///scr_lighting_build( default culling )
//
//  Build shadow casting geometry and render lights, with their shadows, to a screen-space lighting surface.
//  Should be called in one object per room, the same object that called scr_lighting_start().
//  This script changes the d3d_set_culling() internal value!
//  
//  argument0: Culling value to be set after the script has ended.
//  return: Nothing
//  
//  November 2015
//  @jujuadams
//  /u/jujuadam
//  Juju on the GMC
//
//  Based on the YAILSE system by xot (John Leffingwell) of gmlscripts.com
//  
//  This code and engine are provided under the Creative Commons "Attribution - NonCommerical - ShareAlike" international license.
//  https://creativecommons.org/licenses/by-nc-sa/4.0/

scr_lighting_build_1();

if ( lightingBumpSize > 0 ) {
    d3d_set_culling( false );
    scr_lighting_build_2();
}

d3d_set_culling( lightingSelfLighting );
if ( lightingBumpSize > 0 ) scr_lighting_build_3a() else scr_lighting_build_3b();
d3d_set_culling( argument0 );

scr_lighting_build_4();

#define scr_lighting_build_1
///scr_lighting_build_1()

//One-time construction of the static shadow-casting geometry
if ( vbf_staticShadows == noone ) {

    //Create a new vertex buffer
    vbf_staticShadows = vertex_create_buffer();
    
    //Add static shadow caster vertices to the relevant vertex buffer
    vertex_begin( vbf_staticShadows, vft_shadowGeometry );
    with ( obj_static_block ) scr_lighting_add_occlusion( other.vbf_staticShadows );
    vertex_end( vbf_staticShadows );
    
    //Freeze this buffer for speed boosts later on (though only if we have vertices in this buffer)
    if ( vertex_get_number( vbf_staticShadows ) > 0 ) vertex_freeze( vbf_staticShadows );
    
}

//--- Refresh the dynamic geometry
//This is really slow so try to keep dynamic objects limited.
if ( vbf_dynamicShadows != noone ) vertex_delete_buffer( vbf_dynamicShadows );
vbf_dynamicShadows = vertex_create_buffer();

//Add dynamic shadow caster vertices to the relevant vertex buffer
vertex_begin( vbf_dynamicShadows, vft_shadowGeometry );
with ( obj_dynamic_block ) if ( onScreen ) scr_lighting_add_occlusion( other.vbf_dynamicShadows );
vertex_end( vbf_dynamicShadows );

#define scr_lighting_add_occlusion
///scr_lighting_add_occlusion( vertex buffer )
//
//  Adds an object's pre-defined shadow casting geometry to a vertex buffer, after having been appropriately transformed.
//  Should be called with() the shadow casting object.
//
//  return: Nothing
//  
//  November 2015
//  @jujuadams
//  /u/jujuadam
//  Juju on the GMC
//
//  Based on the YAILSE system by xot (John Leffingwell) of gmlscripts.com
//  
//  This code and engine are provided under the Creative Commons "Attribution - NonCommerical - ShareAlike" international license.
//  https://creativecommons.org/licenses/by-nc-sa/4.0/

var vbuff = argument0;
var array, vAx, vAy, vBx, vBy;

//Set up basic transforms to turn relative coordinates in arr_shadowGeometry[] into world-space coordinates
d3d_transform_set_scaling( image_xscale, image_yscale, 0 );
d3d_transform_add_rotation_z( image_angle );
d3d_transform_add_translation( round( x ), round( y ), 0 );

//Loop through every line segment, remembering that we're storing coordinate data sequentially: { Ax1, Ay1, Bx1, Bx1,   Ax2, Ay2, Bx2, Bx2, ... }
for( var i = 0; i < shadowGeometry_size; i += 4 ) {
    
    //Collect first coordinate pair and transform
    array = d3d_transform_vertex( arr_shadowGeometry[i  ], arr_shadowGeometry[i+1], 0 );
    vAx = array[0];
    vAy = array[1];
    
    //Collect second coordinate pair and transform
    array = d3d_transform_vertex( arr_shadowGeometry[i+2], arr_shadowGeometry[i+3], 0 );
    vBx = array[0];
    vBy = array[1];
    
    //Deliberately create vertices the wrong way round (anticlockwise) to take advantage of culling, allowing light into but not out of a shape ("self-lighting")
    //This feature is off by default as it requires some conscientious design to avoid glitches
    vertex_position_3d( vbuff,   vAx, vAy, 0 );
    vertex_position_3d( vbuff,   vBx, vBy, LIGHTING_Z_LIMIT );
    vertex_position_3d( vbuff,   vBx, vBy, 0 );
    
    vertex_position_3d( vbuff,   vAx, vAy, 0 );
    vertex_position_3d( vbuff,   vAx, vAy, LIGHTING_Z_LIMIT );
    vertex_position_3d( vbuff,   vBx, vBy, LIGHTING_Z_LIMIT );
    
}

d3d_transform_set_identity();

#define scr_lighting_build_2
///scr_lighting_build_2()

srf_bump = scr_check_surface( srf_bump, view_wview[LIGHTING_VIEW], view_hview[LIGHTING_VIEW] );
surface_set_target( srf_bump );
    
    //Draw a bump map across the entire screen to act as a room background
    draw_background_tiled( bck_bump,   -( view_xview[LIGHTING_VIEW] mod 32 ), -( view_yview[LIGHTING_VIEW] mod 32 ) );
        
    //Set up a transform to draw everything relative to the view's positon
    d3d_transform_add_translation( -view_xview[LIGHTING_VIEW], -view_yview[LIGHTING_VIEW], 0 );
    
        //Draw all the shadow casters' bump maps
        vertex_submit( vbf_staticBlockBump, pr_trianglelist, sprite_get_texture( spr_static_block, 1 ) );
        with( obj_dynamic_block ) if ( onScreen ) scr_draw_self_image( 1 );
        
    //Reset our draw state 
    d3d_transform_set_identity();
surface_reset_target();

#define scr_lighting_build_3a
///scr_lighting_build_3a()

//Do this once and let all lights access the texture index
var tex = surface_get_texture( srf_bump );

//For each light on the screen...
with ( obj_par_light ) {

    //If they're on screen...
    if ( onScreen ) {
        
        //Target the light's work surface
        surface_set_target( srf_light );
        
        //draw_clear() is expensive. Only clear if the light map sprite is maybe not going to cover the entire surface.
        if ( image_angle != 0 ) or ( abs( image_xscale ) < lightMaxXScale ) or ( abs( image_yscale ) < lightMaxYScale ) draw_clear( c_black );
        
        //Start the bump mapping shader
        shader_set( shd_bump );
            
            //Pass the bump map surface to the shader
            texture_set_stage( shader_get_sampler_index( shd_bump, "smp_bump" ), tex );
            
            //Find the lighting sprite's UV coordinates on its texture page
            //These values are used in the shader to normalise the texture coordinates
            //uvs = sprite_get_uvs( sprite_index, image_index );
            uvs[0] = 0;
            uvs[1] = 0;
            uvs[2] = 1;
            uvs[3] = 1;
            shader_set_uniform_f( shader_get_uniform( shd_bump, "u_lightTopLeft" ),          uvs[0],          uvs[1] );
            shader_set_uniform_f( shader_get_uniform( shd_bump, "u_lightScale" ),    1 / ( uvs[2] - uvs[0] ), 1 / ( uvs[3] - uvs[1] ) );
            
            //Work out the position of the light's texture coordinates on the bump map surface
            var texL = ( ( x - lightWHalf ) - view_xview[LIGHTING_VIEW] ) / view_wview[LIGHTING_VIEW];
            var texT = ( ( y - lightHHalf ) - view_yview[LIGHTING_VIEW] ) / view_hview[LIGHTING_VIEW];
            var texR = ( ( x + lightWHalf ) - view_xview[LIGHTING_VIEW] ) / view_wview[LIGHTING_VIEW];
            var texB = ( ( y + lightHHalf ) - view_yview[LIGHTING_VIEW] ) / view_hview[LIGHTING_VIEW];
            shader_set_uniform_f( shader_get_uniform( shd_bump, "u_bumpTopLeft" ),        texL,        texT );
            shader_set_uniform_f( shader_get_uniform( shd_bump, "u_bumpSize" ),    texR - texL, texB - texT );
            
            //Pass the bump map scale to the shader
            shader_set_uniform_f( shader_get_uniform( shd_bump, "u_scale" ), other.lightingBumpSize );
            
            //Draw the light
            //Unfortunately, scaled and rotated sprites aren't supported yet in bump map mode :(
            //draw_sprite_ext( sprite_index, image_index,    lightWHalf, lightHHalf,    image_xscale, image_yscale, image_angle,    image_blend, 1 );
            //draw_sprite_ext( sprite_index, image_index,    lightWHalf, lightHHalf,    image_xscale, image_yscale, image_angle,    merge_colour( c_black, image_blend, image_alpha ), 1 );
            draw_surface_ext( srf_light, 0, 0, 1, 1, 0, merge_colour( c_black, image_blend, image_alpha ), 1 );
            
        //Turn off the shader
        shader_reset();
        
        //Magical projection!
        d3d_set_projection_perspective( x + lightWHalf, y + lightHHalf,   -lightW, -lightH,   180 );
        
        //Use fogging to force the pixel colour to black
        d3d_set_fog( true, c_black, 0, 0 );
        
        //Tell the GPU to render the shadow geometry
        vertex_submit( other.vbf_staticShadows,  pr_trianglelist, -1 );
        vertex_submit( other.vbf_dynamicShadows, pr_trianglelist, -1 );
        
        //Reset everything
        d3d_set_fog( false, c_black, 0, 0 );
        surface_reset_target();
        
    }
}

#define scr_lighting_build_3b
///scr_lighting_build_3b()

//For each light on the screen...
with ( obj_par_light ) {
    
    //If they're on screen...
    if ( onScreen ) {
        
        //Target the light's work surface
        surface_set_target( srf_light );
        
        //draw_clear() is expensive. Only clear if the light map sprite is maybe not going to cover the entire surface.
        if ( image_angle != 0 ) or ( abs( image_xscale ) < lightMaxXScale ) or ( abs( image_yscale ) < lightMaxYScale ) draw_clear( c_black );
        
        //Draw the light sprite
        draw_sprite_ext( sprite_index, image_index,    lightWHalf, lightHHalf,    image_xscale, image_yscale, image_angle,    merge_colour( c_black, image_blend, image_alpha ), 1 );
        
        //Magical projection!
        d3d_set_projection_perspective( x + lightWHalf, y + lightHHalf,   -lightW, -lightH,   180 );
        
        //Use fogging to force the pixel colour to black (but doesn't force the alpha, giving us relatively smooth shadow borders)
        d3d_set_fog( true, c_black, 0, 0 );
        
        //Tell the GPU to render the shadow geometry
        vertex_submit( other.vbf_staticShadows,  pr_trianglelist, -1 );
        vertex_submit( other.vbf_dynamicShadows, pr_trianglelist, -1 );
        
        //Reset everything
        d3d_set_fog( false, c_black, 0, 0 );
        surface_reset_target();
        
    }
}

#define scr_lighting_build_4
///scr_lighting_build_4()

//Create composite lighting surface
srf_lighting = scr_check_surface( srf_lighting, view_wview[LIGHTING_VIEW], view_hview[LIGHTING_VIEW] );
surface_set_target( srf_lighting );
    
    //Clear the surface with the ambient colour
    draw_clear( lightingAmbientColour );
    
    //Use a cumulative blend mode to add lights together
    draw_set_blend_mode( bm_max );
    with ( obj_par_light ) if ( onScreen ) draw_surface( srf_light, x - lightWHalf - view_xview[LIGHTING_VIEW], y - lightHHalf - view_yview[LIGHTING_VIEW] );
    draw_set_blend_mode( bm_normal );

surface_reset_target();