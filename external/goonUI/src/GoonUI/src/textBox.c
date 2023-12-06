#include "../include/textBox.h"
gnTextBox* NewTextBox(int x, int y)
{
    gnTextBox* tb = calloc(1, sizeof(*tb));
    tb->dirty = 1;
    tb->currentText = "";
    tb->textRect.x = x;
    tb->textRect.y = y;
    tb->textRect.w = tb->textRect.h = 0;
    return tb;
}