### ZeroBrane
- Had to build luasocket from source, as the one from luarocks didn't build right for arm
- Had to get the build command from the mac.cmd file, and use that
- Had to remove -bundle and use these changes:
-LDFLAGS_macosx= -bundle -undefined dynamic_lookup -o
+LDFLAGS_macosx=  -undefined dynamic_lookup -dynamiclib -o
- Had to rename the files and put in a shared lib local location, as for some reason it references core in different places (socket-3.0.0)
- Now when you run (with make run) it will trigger breakpoints set in zerobrane after you start the server.