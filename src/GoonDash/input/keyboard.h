/**
 * @file keyboard.h
 * @author Kevin Blanchard (kevin@supergoon.som)
 * @brief Handles keyboard events
 * @version 0.1
 * @date 2023-10-09
 *
 * @copyright Copyright (c) 2023
 *
 */
#pragma once

typedef union SDL_Event SDL_Event;
typedef struct lua_State lua_State;

int HandleKeyboardEvent(SDL_Event *event, lua_State *L);