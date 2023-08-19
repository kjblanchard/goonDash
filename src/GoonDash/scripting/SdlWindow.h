/**
 * @file SdlWindow.h
 * @author your name (you@domain.com)
 * @brief
 * @version 0.1
 * @date 2023-07-27
 *
 * @copyright Copyright (c) 2023
 *
 */
#pragma once

int InitializeSdlWindowLuaFunctions(lua_State *L);
SDL_Renderer* GetGlobalRenderer();
SDL_Window* GetGlobalWindow();
