#include <gnpch.h>
#include "../include/font.h"

static SDL_Renderer *_renderer;
static int _numLoadedFonts = 0;
static int _capacityLoadedFonts = 4;
static TTF_Font **_loadedFonts;

static void ResizeFontStore()
{
    _capacityLoadedFonts *= 2;
    _loadedFonts = realloc(_loadedFonts, sizeof(_capacityLoadedFonts * sizeof(TTF_Font *)));
    // TODO should make sure realloc works apparently.
}

void InitializeFontStore(SDL_Renderer *renderer)
{
    _renderer = renderer;
    _loadedFonts = calloc(_capacityLoadedFonts, sizeof(TTF_Font *));
}

// gnFont *LoadFont(const char *fontName, int size, SDL_Renderer *renderer)
TTF_Font *LoadFont(const char *fontName, int size)
{
    // gnFont *font = calloc(1, sizeof(*font));
    // TTF_Font *font;
    // printf("Creating font?\n");
    /* MS Himalaya (himalaya.ttf): http://fontzone.net/font-details/microsoft-himalaya */
    const char *path = "assets/fonts/";
    const char * fileType = ".ttf";
    int fullLength = strlen(path) + strlen(fontName) + strlen(fileType) + 1;
    char fullString[fullLength];
    snprintf(fullString, fullLength, "%s%s%s", path, fontName, fileType);
    // font->fontTexture = TTF_OpenFont(fontName, size);
    TTF_Font *font = TTF_OpenFont(fullString, size);
    // font = TTF_OpenFont("assets/fonts/himalaya.ttf", 24);

    if (!font)
    {
        fprintf(stderr, "Could not load font, %s\n", TTF_GetError());
        return NULL;
    }
    return font;
}

gnFont *LoadTextFromFont(TTF_Font *font, const char *text, SDL_Color color)
{
    // This should be when you actually load something to render.
    // SDL_Color colour = {255, 255, 255, 255};
    // SDL_Surface *surface = TTF_RenderUTF8_Blended_Wrapped(font, "Created by: Kevin Blanchard\nWASD to move, Spacebar to jump", colour, 0);
    gnFont *loadedFont = calloc(1, sizeof(*loadedFont));
    SDL_Surface *textSurface = TTF_RenderUTF8_Blended_Wrapped(font, text, color, 0);
    // font->
    loadedFont->fontWidth = textSurface->w;
    loadedFont->fontHeight = textSurface->h;
    if (textSurface == NULL)
    {
        fprintf(stderr, "Could not load text from the texture for text %s", text);
        SDL_FreeSurface(textSurface);
        return NULL;
    }
    loadedFont->fontTexture = SDL_CreateTextureFromSurface(_renderer, textSurface);
    SDL_FreeSurface(textSurface);
    return loadedFont;
}