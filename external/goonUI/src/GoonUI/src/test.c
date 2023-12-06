#include <gnpch.h>
#include <GoonUI/include/test.h>

// This is used inside of SDLWindow
SDL_Texture *g_font;
int g_fontW, g_fontH = 0;

// Quick font test
SDL_Texture *CreateFontTest(SDL_Renderer* renderer)
{
    TTF_Font *font;
    printf("Creating font?\n");
    /* MS Himalaya (himalaya.ttf): http://fontzone.net/font-details/microsoft-himalaya */
    font = TTF_OpenFont("assets/fonts/himalaya.ttf", 24);

    if (!font)
    {
        printf("%s\n", TTF_GetError());
        return NULL;
    }
    SDL_Color colour = {255, 255, 255, 255};
    SDL_Surface *surface = TTF_RenderUTF8_Blended_Wrapped(font, "Created by: Kevin Blanchard\nWASD to move, Spacebar to jump", colour, 0);
    g_fontW = surface->w;
    g_fontH = surface->h;
    if (surface == NULL)
    {
        TTF_CloseFont(font);
        printf("Surface error!\n");
        return NULL;
    }
    SDL_Texture *texture = SDL_CreateTextureFromSurface(renderer, surface);
    return texture;
}

void DrawUI(SDL_Renderer* renderer)
{
    SDL_Rect dstFont = {10,10,g_fontW, g_fontH};
    SDL_RenderCopy(renderer, g_font, NULL, &dstFont);
    SDL_RenderDrawLine(renderer, 0, 11+g_fontH, 20 + g_fontW, 11+g_fontH);
    SDL_RenderDrawLine(renderer, 20 + g_fontW, 0, 20 + g_fontW, 11+g_fontH);
}

int InitializeUi(SDL_Renderer* renderer)
{
    if (TTF_Init() != 0)
    {
        fprintf(stderr, "Could not initialize SDL TTF\n, Error: %s", TTF_GetError());
    }
    g_font = CreateFontTest(renderer);
    printf("Hello world!");
}