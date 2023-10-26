/**
 * @file Physics.h
 * @author Kevin Blanchard (kevin@supergoon.com)
 * @brief Create the lua bindings for chipmunk physics
 * @version 0.1
 * @date 2023-10-26
 *
 * @copyright Copyright (c) 2023
 *
 */
#pragma once

typedef struct lua_State lua_State;
int RegisterPhysicsFunctions(lua_State *L);
