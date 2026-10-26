@echo off
setlocal enabledelayedexpansion
set "JAVA_HOME=C:\Program Files\Java\jdk-23"

if exist "%~dp0..\.env" (
    for /f "usebackq tokens=1,* delims==" %%A in ("%~dp0..\.env") do (
        set "var=%%A"
        if not "!var:~0,1!"=="#" (
            if not "%%A"=="" (
                set "%%A=%%B"
            )
        )
    )
)

call "%~dp0..\..\tools\apache-maven-3.9.9\bin\mvn.cmd" spring-boot:run
