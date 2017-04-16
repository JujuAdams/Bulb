gml_pragma( "global", "__init_d3d();");
// setup the depth variable to a sensible default
global.__d3d=false;
global.__d3dDepth=0;
global.__d3dCamera=camera_create();
global.__d3dPrimKind = -1;
global.__d3dPrimTex = -1;
global.__d3dPrimBuffer=vertex_create_buffer();
vertex_format_begin(); 
	vertex_format_add_position_3d(); 
	vertex_format_add_normal(); 
	vertex_format_add_colour();
	vertex_format_add_textcoord(); 
global.__d3dPrimVF=vertex_format_end();
global.__d3dDeprecatedMessage = [ false ];

enum e__YYM
{
	PointB,
	LineB,
	TriB,
	PointUVB,
	LineUVB,
	TriUVB,
	PointVB,
	LineVB,
	TriVB,	
	Texture,
	Colour,
	NumVerts,
	PrimKind,
	NumPointCols,
	NumLineCols,
	NumTriCols,
	PointCols,
	LineCols,
	TriCols,
	
	// these are used when building model primitives
	V1X,
	V1Y,
	V1Z,
	V1NX,
	V1NY,
	V1NZ,
	V1C,
	V1U,
	V1V,
	
	V2X,
	V2Y,
	V2Z,
	V2NX,
	V2NY,
	V2NZ,
	V2C,
	V2U,
	V2V,
};

enum e__YYMKIND
{
	PRIMITIVE_BEGIN,
	PRIMITIVE_END,
	VERTEX,
	VERTEX_COLOR,
	VERTEX_TEX,
	VERTEX_TEX_COLOR,
	VERTEX_N,
	VERTEX_N_COLOR,
	VERTEX_N_TEX,
	VERTEX_N_TEX_COLOR,
	SHAPE_BLOCK,
	SHAPE_CYLINDER,
	SHAPE_CONE,
	SHAPE_ELLIPSOID,
	SHAPE_WALL,
	SHAPE_FLOOR,
};
