///__read_me()
//  
//  Made by Juju Adams, off the back of work by xot (John Leffingwell) of gmlscripts.com, in November 2015
//  My gratitude to John for his continual and invaluable work in making GM more professional, one script at a time.
//  
//  This dynamic lighting engine is one of the fastest possible approaches in native GM without diving into the wonderful world of shaders.
//  Using polygonal shadow casting geometry avoids costly raycasting and using vertex buffers with a 3D transformation avoids slow on-the-fly 2D primitive drawing.
//  There are drawbacks however; this method uses a seperate pass to render the lighting scene and each light has its own surface. This isn't inexpensive.
//  The moderate reliance on surfaces (and hence VRAM) precludes this method from being reliably applied on mobile devices or HTML5.
//  This method also suffers on older hardware with slower fill rates... though that's inescapable and likely to trip up any shadowing system.
//  
//  Due to the use of 3D transformations for every light, larger lights will run slower than smaller lights. Another factor to consider is the number of dynamic objects.
//  Every step, scr_lighting_build() constructs a vertex buffer containing the dynamic shadow caster objects. The fewer dynamic casters, the better.
//  Static casters, however, are processed much faster and can be used fairly liberally.
//  
//  This code and engine are provided under the Creative Commons "Attribution - NonCommerical - ShareAlike" international license.
//  https://creativecommons.org/licenses/by-nc-sa/4.0/

        //Ok, so a quick word on light sprites:
        //1) No transparency. Light sprites should be completely opaque and cover the entire sprite dimensions.
        //2) Light sprites should treat black as completely off. The ambient tone is introduced later and should not be baked into the light sprites.
        //3) Light sprites should have their origin at the exact centre of the sprite, even if the light rotates (such as flashlights etc).
