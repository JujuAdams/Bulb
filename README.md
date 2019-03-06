# YAILSE
### @jujuadams, after work by @xotmatrix.

*Additional contributions from Alexey Mihailov (@LexPest)*

An extremely efficient polygon-based lighting system, based off of the considerable innovation of John Leffingwell (xot) of GMLscripts.com. The method demonstrated here uses a projection matrix to extend shadow caster vertices to infinity from a focal point; by using a trick with the z-buffer, this can be used to stencil out shadows from a point light source.