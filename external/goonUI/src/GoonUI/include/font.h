/**
 * @file font.h
 * @author your name (you@domain.com)
 * @brief
 * @version 0.1
 * @date 2023-12-06
 *
 * @copyright Copyright (c) 2023
 *
 */
// struct SDL_Texture;
struct TTF_Font;
struct SDL_Renderer;
struct SDL_Color;
typedef struct gnFont
{
    int fontWidth, fontHeight;
    SDL_Texture* fontTexture;
} gnFont;

void InitializeFontStore(SDL_Renderer* renderer);
TTF_Font* LoadFont(const char* fontName, int size);
gnFont* LoadTextFromFont(TTF_Font* font, const char* text, SDL_Color color);