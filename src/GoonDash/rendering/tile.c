#include <GoonDash/gnpch.h>
#include <GoonDash/rendering/tile.h>

// Constants for tilemap and tile size
#define TILE_WIDTH 32
#define TILE_HEIGHT 32
#define NUM_TILES_X 8
#define NUM_TILES_Y 8
#define ATLAS_WIDTH (TILE_WIDTH * NUM_TILES_X)
#define ATLAS_HEIGHT (TILE_HEIGHT * NUM_TILES_Y)




// static SDL_Texture *createTextureAtlasFromPNG(SDL_Renderer *renderer, const char *filePath)
// {
//     SDL_Surface *tileSurface = LoadSurfaceFromFile(filePath);
//     if (!tileSurface)
//         return NULL;
//     SDL_Surface *
//         atlasSurface = SDL_CreateRGBSurfaceWithFormat(0, ATLAS_WIDTH, ATLAS_HEIGHT, 32, SDL_PIXELFORMAT_RGBA8888);

//     // Copy individual tiles from the loaded PNG to the atlas surface
//     for (int y = 0; y < NUM_TILES_Y; y++)
//     {
//         for (int x = 0; x < NUM_TILES_X; x++)
//         {
//             SDL_Rect srcRect = {x * TILE_WIDTH, y * TILE_HEIGHT, TILE_WIDTH, TILE_HEIGHT};
//             SDL_Rect destRect = {x * TILE_WIDTH, y * TILE_HEIGHT, TILE_WIDTH, TILE_HEIGHT};
//             SDL_BlitSurface(tileSurface, &srcRect, atlasSurface, &destRect);
//         }
//     }

//     // Convert the surface to a texture (texture atlas)
//     SDL_Texture *textureAtlas = SDL_CreateTextureFromSurface(renderer, atlasSurface);
//     SDL_FreeSurface(atlasSurface);
//     SDL_FreeSurface(tileSurface);

//     return textureAtlas;
// }