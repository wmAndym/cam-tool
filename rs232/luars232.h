//
//  luars232.h
//  TestBox
//
//  Created by gdlocal on 15-1-7.
//  Copyright (c) 2015年 Jifu.cao. All rights reserved.
//

#ifndef TestBox_luars232_h
#define TestBox_luars232_h

#include "rs232.h"

#define MODULE_TIMESTAMP __DATE__ " " __TIME__
#define MODULE_NAMESPACE "luars232"
#define MODULE_VERSION "1.0.3"
#define MODULE_BUILD "$Id: luars232.c 15 2011-02-23 09:02:20Z sp $"
#define MODULE_COPYRIGHT "Copyright (c) 2011 Petr Stetiar <ynezz@true.cz>, Gaben Ltd."
RS232_LIB int luaopen_luars232(lua_State *L);
RS232_LIB void require_luars232(lua_State *L);
RS232_LIB void stackDump(lua_State* L);
#endif
