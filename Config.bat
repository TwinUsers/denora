@echo off
rem Denora (c) 2004-2013 Denora Team
rem Contact us at info@denorastats.org
rem
rem This program is free but copyrighted software;
rem see the file COPYING for details.
rem
rem Based on the original code of Anope by Anope Team.
rem Based on the original code of Thales by Lucas.
rem
rem 
IF EXIST include\sysconf.h (
	del include\sysconf.h
)
cscript /nologo install.js
