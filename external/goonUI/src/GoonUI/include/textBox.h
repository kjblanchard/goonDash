/**
 * @file textBox.h
 * @author your name (you@domain.com)
 * @brief
 * @version 0.1
 * @date 2023-12-06
 *
 * @copyright Copyright (c) 2023
 *
 */
#include <SDL2/SDL_rect.h>

typedef struct gnTextBox
{
    int dirty;
    const char* currentText;
    SDL_Rect textRect;

} gnTextBox;

gnTextBox* NewTextBox(int x, int y);