
set BASE_INCLUDE=/I. 
set LINK_FLAGS=/link 

set DEFS=/D_WIN32

call cd LuaJIT-2.1\src
call msvc.build.bat
call cd ..
call cl.exe %DEFS% /Fe:bin\windows\srlua.exe src\srlua.c %LINK_FLAGS%
call cl.exe %DEFS% /Fe:bin\windows\glue.exe src\glue.c %LINK_FLAGS%
