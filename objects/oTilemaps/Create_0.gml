occluder = new BulbStaticOccluder(oRenderer6.lighting);

BulbDefineTile(tsTileset, 1, 1).AddEdge( 8,  0,  8,  8).AddEdge( 8,  8,  0,  8);
BulbDefineTile(tsTileset, 2, 1).AddEdge(16,  8,  8,  8).AddEdge( 8,  8,  8,  0);
BulbDefineTile(tsTileset, 3, 1).AddEdge(16,  8,  0,  8);

BulbDefineTile(tsTileset, 0, 2).AddEdge( 0,  8,  8,  8).AddEdge( 8,  8,  8, 16);
BulbDefineTile(tsTileset, 1, 2).AddEdge( 8,  0,  8, 16);
BulbDefineTile(tsTileset, 2, 2).AddEdge(16,  8,  8,  8).AddEdge( 8,  8,  8,  0).AddEdge( 0,  8,  8,  8).AddEdge( 8,  8,  8, 16);
BulbDefineTile(tsTileset, 3, 2).AddEdge(16,  8,  8,  8).AddEdge( 8,  8,  8, 16);

BulbDefineTile(tsTileset, 0, 3).AddEdge( 8, 16,  8,  8).AddEdge( 8,  8, 16,  8);
BulbDefineTile(tsTileset, 1, 3).AddEdge( 8,  0,  8,  8).AddEdge( 8,  8,  0,  8).AddEdge( 8, 16,  8,  8).AddEdge( 8,  8, 16,  8);
BulbDefineTile(tsTileset, 2, 3).AddEdge( 8, 16,  8,  0);
BulbDefineTile(tsTileset, 3, 3).AddEdge( 8, 16,  8,  8).AddEdge( 8,  8,  0,  8);

BulbDefineTile(tsTileset, 0, 4).AddEdge( 0,  8, 16,  8);
BulbDefineTile(tsTileset, 1, 4).AddEdge( 8,  0,  8,  8).AddEdge( 8,  8, 16,  8);
BulbDefineTile(tsTileset, 2, 4).AddEdge( 0,  8,  8,  8).AddEdge( 8,  8,  8,  0);

BulbAddTilemapToOccluder(occluder, layer_tilemap_get_id("Tiles"));

BulbTilesetEdgeTrace(tsTileset4);

BulbTilesetEdgeTrace(tsTileset2);
BulbAddTilemapToOccluder(occluder, layer_tilemap_get_id("Tiles2"));

BulbTilesetEdgeTrace(tsTileset3);
BulbAddTilemapToOccluder(occluder, layer_tilemap_get_id("Tiles3"));

BulbTilesetEdgeTrace(tsTileset4);
BulbAddTilemapToOccluder(occluder, layer_tilemap_get_id("Tiles4"));