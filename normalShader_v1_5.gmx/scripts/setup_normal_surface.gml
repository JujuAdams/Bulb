#define setup_normal_surface
if(!lightingEnabled){ return -1; }
var w, h, result;
result = 1;
w = view_wview[0];
while(result < w){ 
    result = result << 1; 
}
w = result;
result = 1;
h = view_hview[0];
while(result < h){ 
    result = result << 1; 
}
h = result;
if(!surface_exists(normalSurface)){
normalSurface = surface_create(w,h);
}

#define setup_lighting_surface
if(!lightingEnabled){ return -1; }
var w, h, result;
result = 1;
w = view_wview[0];
while(result < w){ 
    result = result << 1; 
}
w = result;
result = 1;
h = view_hview[0];
while(result < h){ 
    result = result << 1; 
}
h = result;
if(!surface_exists(lightSurface)){
lightSurface = surface_create(w,h);
}

#define setup_specular_surface
if(!lightingEnabled){ return -1; }
var w, h, result;
result = 1;
w = view_wview[0];
while(result < w){ 
    result = result << 1; 
}
w = result;
result = 1;
h = view_hview[0];
while(result < h){ 
    result = result << 1; 
}
h = result;
if(!surface_exists(specularSurface)){
specularSurface = surface_create(w,h);
}

#define clear_normal_surface
if(!lightingEnabled){ return -1; }
surface_set_target(normalSurface);
draw_clear_alpha(make_colour_rgb(128,128,255),0);
surface_reset_target();

#define clear_lighting_surface
///clear_lighting_suface(ambient_color)
if(!lightingEnabled){ return -1; }
var ambientCol;
ambientCol = make_colour_rgb(30,23,72);
//ambientCol = make_colour_rgb(10,7,24); //gamma correct (better ambience)
if(argument_count > 0){ ambientCol = argument[0]; }
surface_set_target(lightSurface);
draw_clear_alpha(ambientCol,1);
surface_reset_target();

#define clear_specular_surface
if(!lightingEnabled){ return -1; }
surface_set_target(specularSurface);
draw_clear_alpha(make_colour_rgb(0,0,0),0);
surface_reset_target();

#define lighting_setup
globalvar normalScale, normalRot, lightingPos, lightingCol, lightingRad, lightingRes, lightingType, lightingEnabled, lightingSpecMap;
var w, h, result;
result = 1;
w = view_wview[0];
while(result < w){ 
    result = result << 1; 
}
w = result;
result = 1;
h = view_hview[0];
while(result < h){ 
    result = result << 1; 
}
h = result;

normalScale = shader_get_uniform( normalFixing, "signScale" );
normalRot = shader_get_uniform( normalFixing, "rotation" );

lightingRes = shader_get_uniform( normalLighting, "res" );
lightingPos = shader_get_uniform( normalLighting, "lightPos" );
lightingCol = shader_get_uniform( normalLighting, "lightColor" );
lightingRad = shader_get_uniform( normalLighting, "lightRad" );
lightingType = shader_get_uniform( normalLighting, "type" );

lightingSpecMap = shader_get_sampler_index( normalLighting, "specMap" );
//lightingSpec = shader_get_uniform( normalLighting, "spec" );

globalvar normalSurface;
normalSurface = surface_create(w,h);

globalvar lightSurface;
lightSurface = surface_create(w,h);

globalvar specularSurface;
specularSurface = surface_create(w,h);

lightingEnabled = true;

#define draw_normals_begin
if(!lightingEnabled){ return -1; }
surface_set_target(normalSurface)

#define draw_normals_ext
///draw_normals_ext(signXscale,signYscale,rotation)
if(!lightingEnabled){ return -1; }
shader_set(normalFixing)
shader_set_uniform_f( normalScale, argument0, argument1 );
shader_set_uniform_f( normalRot, cos(degtorad(argument2)), sin(degtorad(argument2)) );

#define draw_lighting_complete
if(!lightingEnabled){ return -1; }
shader_reset();
surface_reset_target();
draw_set_blend_mode(bm_normal);

#define draw_light
///draw_light(x,y,z,rad,pointLight,color,alpha)
if(!lightingEnabled){ return -1; }
var w, h, result;
result = 1;
w = view_wview[0];
while(result < w){ 
    result = result << 1; 
}
w = result;
result = 1;
h = view_hview[0];
while(result < h){ 
    result = result << 1; 
}
h = result;
if(argument4){
    var tx, ty, tw, th, lx, ly;
    lx = argument0-view_xview[0];
    ly = argument1-view_yview[0];
    tx = max(lx-argument3,0);
    ty = max(ly-argument3,0);
    tw = min(lx+argument3,view_wview[0])-tx;
    th = min(ly+argument3,view_hview[0])-ty;
    if(tw<=0 or th<=0){ exit; }
}
surface_set_target(lightSurface);
draw_set_blend_mode(bm_add);
shader_set(normalLighting);
shader_set_uniform_f( lightingRes, w, h );
if(argument4){
    shader_set_uniform_f( lightingPos, lx/w, ly/h, argument2 );
} else {
    shader_set_uniform_f( lightingPos, argument0, argument1, argument2 );
}
shader_set_uniform_f( lightingCol, colour_get_red(argument5)/255,
    colour_get_green(argument5)/255, colour_get_blue(argument5)/255, argument6 );
shader_set_uniform_f( lightingRad, argument3 );
shader_set_uniform_f( lightingType, argument4 );
//specular
texture_set_stage( lightingSpecMap, surface_get_texture(specularSurface));
if(argument4){
    draw_surface_part(normalSurface,tx,ty,tw,th,tx,ty);
} else {
    draw_surface_part(normalSurface,0,0,view_wview[0],view_hview[0],0,0);
}
draw_lighting_complete();

#define add_lighting
///add_lighting(celShading)
if(!lightingEnabled){ return -1; }
draw_set_blend_mode_ext(bm_dest_color, bm_zero);
if(argument0){ shader_set(celShading); }
//shader_set(gammaCorrect);
draw_surface(lightSurface,view_xview[0],view_yview[0]);
draw_lighting_complete()

#define show_normals
if(!lightingEnabled){ return -1; }
draw_surface(normalSurface,view_xview[0],view_yview[0]);

#define show_lighting
///show_lighting(celShading)
if(!lightingEnabled){ return -1; }
if(argument0){ shader_set(celShading); }
//shader_set(gammaCorrect);
draw_surface(lightSurface,view_xview[0],view_yview[0]);
draw_lighting_complete();

#define lighting_enable
///lighting_enable(true/false)
if(argument0){
    if(!lightingEnabled){
        lighting_setup();
    }
} else {
    if(lightingEnabled){
        lightingEnabled = false;
        if(surface_exists(normalSurface)){ surface_free(normalSurface); }
        if(surface_exists(lightSurface)){ surface_free(lightSurface); }
    }
}
#define draw_specular_begin
if(!lightingEnabled){ return -1; }
surface_set_target(specularSurface)