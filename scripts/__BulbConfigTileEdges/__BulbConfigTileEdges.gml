enum BULB_EDGE
{
    RIGHT   = 1,
    R       = 1,
    TOP     = 2,
    T       = 2,
    LEFT    = 4,
    L       = 4,
    BOTTOM  = 8,
    B       = 8,
}

function __BulbTileEdgeAdd(_struct, _x, _y, _value)
{
    _struct[$ (_x + _y*8)] = _value;
}

function __BulbConfigTileEdges()
{
    var _struct = {};
    
    __BulbTileEdgeAdd(_struct, 0, 2, BULB_EDGE.L);
    __BulbTileEdgeAdd(_struct, 1, 2, BULB_EDGE.L);
    __BulbTileEdgeAdd(_struct, 2, 2, BULB_EDGE.L);
    __BulbTileEdgeAdd(_struct, 3, 2, BULB_EDGE.L);
    
    __BulbTileEdgeAdd(_struct, 4, 2, BULB_EDGE.T);
    __BulbTileEdgeAdd(_struct, 5, 2, BULB_EDGE.T);
    __BulbTileEdgeAdd(_struct, 6, 2, BULB_EDGE.T);
    __BulbTileEdgeAdd(_struct, 7, 2, BULB_EDGE.T);
    
    __BulbTileEdgeAdd(_struct, 0, 3, BULB_EDGE.R);
    __BulbTileEdgeAdd(_struct, 1, 3, BULB_EDGE.R);
    __BulbTileEdgeAdd(_struct, 2, 3, BULB_EDGE.R);
    __BulbTileEdgeAdd(_struct, 3, 3, BULB_EDGE.R);
    
    __BulbTileEdgeAdd(_struct, 0, 4, BULB_EDGE.L | BULB_EDGE.R);
    __BulbTileEdgeAdd(_struct, 1, 4, BULB_EDGE.T);
    __BulbTileEdgeAdd(_struct, 2, 4, BULB_EDGE.L | BULB_EDGE.T);
    __BulbTileEdgeAdd(_struct, 3, 4, BULB_EDGE.L | BULB_EDGE.T);
    
    __BulbTileEdgeAdd(_struct, 4, 4, BULB_EDGE.R | BULB_EDGE.T);
    __BulbTileEdgeAdd(_struct, 5, 4, BULB_EDGE.R | BULB_EDGE.T);
    __BulbTileEdgeAdd(_struct, 6, 4, BULB_EDGE.R);
    __BulbTileEdgeAdd(_struct, 7, 4, BULB_EDGE.R);
    
    __BulbTileEdgeAdd(_struct, 0, 5, BULB_EDGE.L);
    __BulbTileEdgeAdd(_struct, 1, 5, BULB_EDGE.L);
    __BulbTileEdgeAdd(_struct, 2, 5, BULB_EDGE.L | BULB_EDGE.T | BULB_EDGE.R);
    __BulbTileEdgeAdd(_struct, 3, 5, BULB_EDGE.T);
    
    __BulbTileEdgeAdd(_struct, 4, 5, BULB_EDGE.L | BULB_EDGE.R);
    __BulbTileEdgeAdd(_struct, 5, 5, BULB_EDGE.T);
    __BulbTileEdgeAdd(_struct, 6, 5, BULB_EDGE.L | BULB_EDGE.T | BULB_EDGE.R);
    
    global.__bulbTileEdges[$ tsTileset3] = _struct;
}