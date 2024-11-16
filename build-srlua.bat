
set BASE_INCLUDE=/I. /ILuaJIT-2.1/src /Isrc
set LINK_FLAGS=/link 

set DEFS=/D_WIN32

call cd LuaJIT-2.1\src
call msvcbuild.bat
call xcopy /Y luajit.exe ..\..\bin\windows\
call xcopy /Y luajit.lib ..\..\bin\windows\
call xcopy /Y lua51.lib ..\..\bin\windows\
call xcopy /Y lua51.dll ..\..\bin\windows\
call cd ..\..
call cl.exe %DEFS% %BASE_INCLUDE% /Fe:bin\windows\srlua.exe src\srlua.c %LINK_FLAGS% /LIBPATH:".\bin\windows" "luajit.lib" "lua51.lib" "user32.lib" 
call cl.exe %DEFS% %BASE_INCLUDE% /Fe:bin\windows\glue.exe src\glue.c %LINK_FLAGS%
