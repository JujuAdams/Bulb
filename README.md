<p align="center"><img src="https://raw.githubusercontent.com/JujuAdams/Bulb/master/LOGO.png" style="display:block; margin:auto; width:300px"></p>

<h1 align="center">19.0.0</h1>

<p align="center">2D lighting and shadows for GameMaker Studio 2.3.1 by <b>@jujuadams</b></p>

<p align="center"><a href="https://github.com/JujuAdams/Bulb/releases/tag/19.0.0">Download the .yymp</a></p>
<p align="center">Chat about Bulb on the <a href="https://discord.gg/8krYCqr">Discord server</a></p>

&nbsp;

*Additional contributions from John Leffingwell (@xotmatrix) and Alexey Mihailov (@LexPest)*

An extremely efficient polygon-based lighting system, based off of the considerable innovation of John Leffingwell (xot) of GMLscripts.com. The method demonstrated here uses a projection matrix to extend shadow caster vertices to infinity from a focal point; by using a trick with the z-buffer, this can be used to stencil out shadows from a point light source.
