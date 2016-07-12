@echo off
support\masm /mx /t test.asm;
support\link /noi /tiny /nologo test.obj,test.com,nul,tony.lib;
