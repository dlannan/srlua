
# srlua

This is a fork of the brilliant original srlua.

The tool has ahd a little modification to be able to handle a combine.lua
script that allows the building of multiple lua scripts into a single 
executable.

## Usage

### Combine

If you need to first combine many lua scripts, use the combine.lua like so:

```./bin/windows/luajit.exe combine.lua main_1.lua main_2.lua -L lib_1.lua lib_2.lua```

The above script takes main_1 and main_2 as the primary executable files (they will be 
executed upon running). The files after the -L switch are preloaded lua script 
packages that will be referenced the same as they would be with require in lua.

If main_1 has ```local mylib_1 = require("lib_1")``` then it will load 
lib_1 into the mylib_1 variable. 

All requires should use platform specific sfile separators or dot notation.

The resulting output will be a luac.out file that can then be used by srlua.

### srlua

Using the combine output to build the executable.

```./bin/windows/glue.exe ./bin/windows/srlua.exe luac.out mynewexe.exe```

The name of luac.out can be modified by editing the combine.lua script.

The resulting executable should run on the target os directly. 

In the case of Windows, it is necessary to include the lua51.dll with any 
executable produced, since it will attempt to load this dll.

-----

This is a self-running Lua interpreter. It is meant to be combined with a
Lua program (which may be in either text or precompiled form) into a single,
stand-alone program that will run the given Lua program when it is run.

The command-line arguments will be available to the Lua program in a table
called "arg" and also as '...'. All standard Lua libraries will be available
too. If you want to use a different set of libraries, just copy linit.c from
the Lua source, add it to srlua.c and edit luaL_openlibs to suit your needs.

The Makefile is targeted at Unix systems. Just edit it to reflect your
installation of Lua. Then run make. This will build srlua and glue, and run
a simple test. For each Lua program that you want to turn into a stand-alone
program, do
	glue srlua prog.lua a.out
	chmod +x a.out
Of course, you can use any name instead of a.out.

For Windows, you need to create srlua.exe and glue.exe first. Then for each
Lua program that you want to turn into a stand-alone program, do
	glue srlua.exe prog.lua prog.exe
Of course, you can use any name instead of prog.exe.

This code is hereby placed in the public domain.
Please send comments, suggestions, and bug reports to lhf@tecgraf.puc-rio.br .
