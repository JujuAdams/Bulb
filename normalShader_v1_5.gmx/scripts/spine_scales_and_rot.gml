#define spine_scales_and_rot
///spine_scales_and_rot(list of bones,spr,list angle defaults)
if(!lightingEnabled){ return -1; }
var i, tem;
tem=ds_list_find_value(argument2,0);
var map = ds_map_create();
axscale[ds_list_size(argument0)-1] = 1;
ayscale[ds_list_size(argument0)-1] = 1;
axrot[ds_list_size(argument0)-1] = 0;
ayrot[ds_list_size(argument0)-1] = 0;
for(i=0;i<ds_list_size(argument0);i+=1){
    skeleton_bone_state_get(ds_list_find_value(argument0,i), map);
    axscale[i] = sign(ds_map_find_value(map,"worldScaleX"))*image_xscale;
    ayscale[i] = sign(ds_map_find_value(map,"worldScaleY"))*image_yscale;
    axrot[i] = cos(degtorad(image_angle-ds_list_find_value(argument2,i)+ds_map_find_value(map,"worldAngle")));
    ayrot[i] = sin(degtorad(image_angle-ds_list_find_value(argument2,i)+ds_map_find_value(map,"worldAngle")));
    ds_map_clear(map);
}
ds_map_destroy(map);
uniXscale = shader_get_uniform(spineNormal,"xscale");
uniYscale = shader_get_uniform(spineNormal,"yscale");
uniXrot = shader_get_uniform(spineNormal,"xrot");
uniYrot = shader_get_uniform(spineNormal,"yrot");
uniParts = shader_get_sampler_index(spineNormal, "partSkin")
uniNormals = shader_get_sampler_index(spineNormal, "normalSkin")

uniNewTex = shader_get_sampler_index(spineTexSwap, "newSkin")

var normals, parts, specs;
parts = surface_create(sprite_get_width(argument1),sprite_get_height(argument1));
normals = surface_create(sprite_get_width(argument1),sprite_get_height(argument1));
specs = surface_create(sprite_get_width(argument1),sprite_get_height(argument1));

surface_set_target(parts);
draw_clear_alpha(c_black,0);
draw_sprite(argument1,0,0,0);
surface_reset_target();
surface_set_target(normals);
draw_clear_alpha(make_colour_rgb(128,128,1),0);
draw_sprite(argument1,1,0,0);
surface_reset_target();
surface_set_target(specs);
draw_clear_alpha(c_black,0);
draw_sprite(argument1,2,0,0);
surface_reset_target();

shader_set(spineNormal);

shader_set_uniform_f_array(uniXscale,axscale[]);
shader_set_uniform_f_array(uniYscale,ayscale[]);
shader_set_uniform_f_array(uniXrot,axrot[]);
shader_set_uniform_f_array(uniYrot,ayrot[]);
texture_set_stage(uniParts, surface_get_texture(parts));
texture_set_stage(uniNormals, surface_get_texture(normals));

draw_normals_begin()
x-=view_xview[0];
y-=view_yview[0];
draw_self();
x+=view_xview[0];
y+=view_yview[0];
draw_lighting_complete();

draw_specular_begin();

shader_set(spineTexSwap);

texture_set_stage(uniNewTex, surface_get_texture(specs));

x-=view_xview[0];
y-=view_yview[0];
draw_self();
x+=view_xview[0];
y+=view_yview[0];
draw_lighting_complete();

surface_free(parts);
surface_free(normals);
surface_free(specs);


#define debug_spine_rot
///spine_scales_and_rot(list of bones)
var map = ds_map_create();
ini_open("Debug")
for(i=0;i<ds_list_size(argument0);i+=1){
    skeleton_bone_state_get(ds_list_find_value(argument0,i), map);
    ini_write_string(ds_list_find_value(argument0,i),string(num),string(ds_map_find_value(map,"worldAngle")));
    ds_map_clear(map);
}
ini_close()
ds_map_destroy(map);